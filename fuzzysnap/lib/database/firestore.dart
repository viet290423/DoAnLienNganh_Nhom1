import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts =
      FirebaseFirestore.instance.collection('Posts');

  Future<void> addPost(String message, File imageFile) async {
    // // Truy vấn để lấy username từ collection User
    // DocumentSnapshot userDoc = await FirebaseFirestore.instance
    //     .collection('User')
    //     .doc(user!.email)
    //     .get();

    // String? username = userDoc.get('username');

    // Upload image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(imageFile);
    String imageUrl = await storageRef.getDownloadURL();

    // Save post data with image URL and message
    await posts.add({
      'UserEmail': user!.email,
      // 'UserName': username,
      'PostMessage': message,
      'ImageUrl': imageUrl,
      'TimeStamp': Timestamp.now(),
    });
  }

  // Hàm lấy stream các bài đăng
  Stream<QuerySnapshot> getPostsStream() {
    return posts.orderBy('TimeStamp', descending: true).snapshots();
  }
}
