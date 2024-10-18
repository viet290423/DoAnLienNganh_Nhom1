import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/service/chat_service.dart';

class FriendRequestsService {
  final ChatService _chatService = ChatService(); // Tạo một instance của ChatService

  // Lấy các yêu cầu kết bạn của người dùng hiện tại
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('Người dùng hiện tại không tồn tại.');
        return [];
      }

      // Lấy các yêu cầu kết bạn từ collection FriendRequests
      DocumentSnapshot<Map<String, dynamic>> requestsDoc =
      await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(currentUser.uid)
          .get();

      if (!requestsDoc.exists) {
        debugPrint('Không có yêu cầu kết bạn.');
        return [];
      }

      // Trả về danh sách yêu cầu kết bạn
      return List<Map<String, dynamic>>.from(requestsDoc.data()?['requests'] ?? []);
    } catch (e) {
      debugPrint('Lỗi khi lấy yêu cầu kết bạn: $e');
      return [];
    }
  }

  // Chấp nhận yêu cầu kết bạn
  Future<void> acceptFriendRequest(Map<String, dynamic> friendRequest) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('Người dùng hiện tại không tồn tại.');
        return;
      }

      String currentUserEmail = currentUser.email ?? '';

      // Tìm kiếm thông tin của người gửi trong collection 'User'
      DocumentSnapshot<Map<String, dynamic>> currentDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUserEmail)
          .get();

      if (!currentDoc.exists) {
        debugPrint('Không tìm thấy thông tin người dùng hiện tại.');
        return;
      }

      Map<String, dynamic>? currentData = currentDoc.data();
      String currentUserUid = currentData?['uid'] ?? '';
      String currentUsername = currentData?['username'] ?? 'Unknown';
      String currentProfileImage = currentData?['profile_image'] ?? 'default_profile_image_url';

      // Xóa yêu cầu kết bạn khỏi FriendRequests sau khi chấp nhận
      await _removeFriendRequest(currentUserUid, friendRequest);

      // Thêm bạn vào danh sách bạn bè trong collection User
      await _addFriendToUser(currentUserEmail, friendRequest);

      // Thêm người dùng hiện tại vào danh sách bạn bè của người gửi yêu cầu
      await _addFriendToRequester(friendRequest, currentUserUid, currentUserEmail, currentUsername, currentProfileImage);

      // Tạo chat box mới
      await _chatService.getChatBoxId(currentUserUid, friendRequest['uid']); // Tạo chat box mới

      debugPrint('Đã chấp nhận yêu cầu kết bạn.');
    } catch (e) {
      debugPrint('Lỗi khi chấp nhận yêu cầu kết bạn: $e');
    }
  }

  // Xóa yêu cầu kết bạn
  Future<void> declineFriendRequest(Map<String, dynamic> friendRequest) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('Người dùng hiện tại không tồn tại.');
        return;
      }

      await _removeFriendRequest(currentUser.uid, friendRequest);

      debugPrint('Đã xóa yêu cầu kết bạn.');
    } catch (e) {
      debugPrint('Lỗi khi xóa yêu cầu kết bạn: $e');
    }
  }

  // Hàm phụ trợ để xóa yêu cầu kết bạn
  Future<void> _removeFriendRequest(String userId, Map<String, dynamic> friendRequest) async {
    await FirebaseFirestore.instance
        .collection('FriendRequests')
        .doc(userId)
        .update({
      'requests': FieldValue.arrayRemove([friendRequest])
    });
  }

  // Hàm phụ trợ để thêm bạn vào danh sách bạn bè của người dùng
  Future<void> _addFriendToUser(String currentUserEmail, Map<String, dynamic> friendRequest) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(currentUserEmail)
        .update({
      'listFriend': FieldValue.arrayUnion([
        {
          'uid': friendRequest['uid'],
          'email': friendRequest['email'],
          'username': friendRequest['username'],
          'profile_image': friendRequest['profile_image'],
        }
      ])
    });
  }

  // Hàm phụ trợ để thêm người dùng hiện tại vào danh sách bạn bè của người gửi yêu cầu
  Future<void> _addFriendToRequester(Map<String, dynamic> friendRequest, String currentUserUid, String currentUserEmail, String currentUsername, String currentProfileImage) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(friendRequest['email'])
        .update({
      'listFriend': FieldValue.arrayUnion([
        {
          'uid': currentUserUid,
          'email': currentUserEmail,
          'username': currentUsername,
          'profile_image': currentProfileImage,
        }
      ])
    });
  }
}
