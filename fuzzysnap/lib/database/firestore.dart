import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts =
      FirebaseFirestore.instance.collection('Posts');

  Future<String> addPost(String message, File imageFile) async {
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

    // Tạo document ID cho bài post
    String postId = posts.doc().id;

    // Save post data with image URL, message, and postId
    await posts.doc(postId).set({
      'UserEmail': user!.email,
      // 'UserName': username,
      'PostMessage': message,
      'ImageUrl': imageUrl,
      'TimeStamp': Timestamp.now(),
      'PostId': postId, // Lưu postId vào Firestore
    });

    return postId; // Trả về postId để sử dụng sau
  }

  // Hàm lấy stream các bài đăng
  Stream<QuerySnapshot> getPostsStream() {
    return posts.orderBy('TimeStamp', descending: true).snapshots();
  }
}
