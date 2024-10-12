import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  // Lấy CollectionReference của bài đăng dựa trên email người dùng
  CollectionReference getUserPostsCollection(String userEmail) {
    return FirebaseFirestore.instance
        .collection('UserPosts')
        .doc(userEmail)
        .collection('Posts');
  }

  // Lấy CollectionReference của comments dựa trên postId và userEmail
  CollectionReference getCommentsCollection(String userEmail, String postId) {
    return getUserPostsCollection(userEmail).doc(postId).collection('Comments');
  }

  // Lấy danh sách email bạn bè của người dùng
  Future<List<String>> getFriendEmails() async {
    if (user == null) return [];

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user!.email) // Dùng email làm ID
          .get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> listFriend = userData?['listFriend'] ?? [];
      return listFriend.map<String>((friend) => friend['email'].toString()).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách bạn bè: $e');
      return [];
    }
  }

  // Lấy Stream của tất cả các bài đăng (người dùng và bạn bè)
  Stream<List<DocumentSnapshot>> getAllPostsStream() async* {
    if (user == null) {
      yield* Stream.error('User not authenticated');
      return;
    }

    try {
      // Lấy danh sách email bạn bè và thêm email của chính người dùng
      List<String> friendEmails = await getFriendEmails();
      friendEmails.add(user!.email!);

      // Tạo Stream cho mỗi người dùng
      List<Stream<QuerySnapshot>> postStreams = friendEmails.map((email) {
        return getUserPostsCollection(email)
            .orderBy('TimeStamp', descending: true)
            .snapshots();
      }).toList();

      // Kết hợp tất cả các Stream
      yield* CombineLatestStream.list(postStreams).map((snapshotList) {
        List<DocumentSnapshot> allPosts = [];
        for (var snapshot in snapshotList) {
          allPosts.addAll(snapshot.docs);
        }

        // Sắp xếp lại các bài đăng theo thời gian
        allPosts.sort((a, b) {
          Timestamp timeA = a['TimeStamp'];
          Timestamp timeB = b['TimeStamp'];
          return timeB.compareTo(timeA);
        });

        return allPosts;
      });
    } catch (e) {
      yield* Stream.error('Lỗi khi lấy bài đăng: $e');
    }
  }

  // Hàm để đăng bài
  Future<void> addPost(String message, File? imageFile) async {
    if (user == null) return;

    try {
      String? imageUrl;
      String userEmail = user!.email!;
      String postId = FirebaseFirestore.instance.collection('Posts').doc().id;
      Timestamp timestamp = Timestamp.now();

      // Nếu có ảnh, lưu ảnh lên Firebase Storage và lấy URL
      if (imageFile != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('$userEmail/$postId.jpg');

        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Tạo bài đăng và lưu vào Firestore
      await getUserPostsCollection(userEmail).doc(postId).set({
        'PostId': postId,
        'UserEmail': userEmail,
        'PostMessage': message,
        'ImageUrl': imageUrl ?? '',
        'TimeStamp': timestamp,
      });

      print('Bài đăng đã được thêm thành công!');
    } catch (e) {
      print('Lỗi khi đăng bài: $e');
    }
  }

  // Hàm xóa bài đăng dựa trên postId
  Future<void> removePost(String postId) async {
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Xóa bài đăng trong Firestore dựa trên postId
      await getUserPostsCollection(user!.email!).doc(postId).delete();

      // Hiển thị thông báo thành công
      print('Post removed successfully');
    } catch (e) {
      // In thông báo lỗi nếu có
      print('Error removing post: $e');
      throw Exception('Error removing post');
    }
  }
}

