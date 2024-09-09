import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  //Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    // Begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) {
      throw Exception('User canceled Google sign-in');
    }

    // Obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Finally, let's sign in
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Add user to Firestore if not exists
    await _addUserToFirestore(userCredential.user);

    return userCredential;
  }

  // Thêm người dùng vào Firestore nếu chưa tồn tại
  Future<void> _addUserToFirestore(User? user) async {
    if (user != null) {
      // Kiểm tra xem người dùng đã có trong Firestore chưa
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('User').doc(user.email);
      DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Nếu chưa có, thêm thông tin người dùng vào Firestore
        await userRef.set({
          'username':
              user.displayName ?? 'Unknown', // Lấy username từ Google profile
          'email': user.email,
          'profile_image':
              user.photoURL ?? '', // Lấy avatar từ Google profile nếu có
          'created_at': Timestamp.now(),
        });
      }
    }
  }
}
