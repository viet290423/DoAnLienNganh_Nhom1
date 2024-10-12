import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuzzysnap/database/firestore.dart';


class CommentService {
  User? user = FirebaseAuth.instance.currentUser;
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();


  // Hàm thêm bình luận vào bài đăng
  Future<void> addComment(String postId, String userEmail, String commentText) async {
    if (user == null) return;

    try {
      // Truy vấn userName và avatar của người dùng từ Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user!.email)
          .get();

      // Lấy userName và avatar URL từ document
      String? userName = userDoc['username'];
      String? avatarUrl = userDoc['profile_image'];

      if (userName == null || avatarUrl == null) {
        throw Exception('Username or Avatar not found');
      }

      String commentId = _firestoreDatabase.getCommentsCollection(userEmail, postId).doc().id;
      Timestamp timestamp = Timestamp.now();

      // Tạo bình luận và lưu vào Firestore
      await _firestoreDatabase.getCommentsCollection(userEmail, postId).doc(commentId).set({
        'CommentId': commentId,
        'UserEmail': user!.email!,
        'UserName': userName,
        'AvatarUrl': avatarUrl,
        'CommentText': commentText,
        'CommentTime': timestamp,
      });

      print('Bình luận đã được thêm thành công!');
    } catch (e) {
      print('Lỗi khi thêm bình luận: $e');
    }
  }

  // Lấy Stream của các comment cho một bài đăng
  Stream<List<DocumentSnapshot>> getCommentsStream(String postId, String userEmail) {
    return _firestoreDatabase.getCommentsCollection(userEmail, postId)
        .orderBy('CommentTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
