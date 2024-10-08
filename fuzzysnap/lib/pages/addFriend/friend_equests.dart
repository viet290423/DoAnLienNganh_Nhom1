import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestsService {
  // Lấy các yêu cầu kết bạn của người dùng hiện tại
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    try {
      // Lấy UID của người dùng hiện tại
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

      List<dynamic> requests = requestsDoc.data()?['requests'] ?? [];

      // Trả về danh sách yêu cầu kết bạn
      return requests.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Lỗi khi lấy yêu cầu kết bạn: $e');
      return [];
    }
  }

  // Chấp nhận yêu cầu kết bạn
  Future<void> acceptFriendRequest(Map<String, dynamic> friendRequest) async {
    try {
      // Lấy người dùng hiện tại
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('Người dùng hiện tại không tồn tại.');
        return;
      }

      String currentUserUid = currentUser.uid; // Lấy UID của người dùng hiện tại
      String currentUserEmail = currentUser.email ?? ''; // Lấy email của người dùng hiện tại

      debugPrint('UID người dùng hiện tại: $currentUserUid');
      debugPrint("Email người dùng hiện tại: $currentUserEmail");

       // Tìm kiếm thông tin của người gửi trong collection 'User'
      DocumentSnapshot<Map<String, dynamic>> currentDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUserEmail)
          .get();

      // Kiểm tra nếu dữ liệu của người gửi tồn tại
      if (!currentDoc.exists) {
        debugPrint('Không tìm thấy thông tin người dùng hiện tại.');
        return;
      }

      Map<String, dynamic>? currentData = currentDoc.data();
      String Display = currentData?['username'] ?? 'Unknown';
      String currentProfileImage = currentData?['profile_image'] ?? 'default_profile_image_url';

      debugPrint('Tên người dùng hiện tại: $Display');
      
      // Xóa yêu cầu kết bạn khỏi FriendRequests sau khi chấp nhận
      await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(currentUserUid) // Sử dụng UID để làm ID của tài liệu
          .update({
        'requests': FieldValue.arrayRemove([friendRequest])
      });

      // Thêm bạn vào danh sách bạn bè trong collection User
      await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUserEmail) // Sử dụng email của người dùng hiện tại
          .update({
        'listFriend': FieldValue.arrayUnion([
          {
            'email': friendRequest['email'], // email của người bạn
            'username': friendRequest['username'], // Tên người bạn
            'profile_image': friendRequest['profile_image'], // Ảnh đại diện của người bạn
          }
        ])
      });

      // Thêm người dùng hiện tại vào danh sách bạn bè của người gửi yêu cầu
      await FirebaseFirestore.instance
          .collection('User')
          .doc(friendRequest[
              'email']) // Sử dụng email của người gửi yêu cầu kết bạn
          .update({
        'listFriend': FieldValue.arrayUnion([
          {
            'email': currentUserEmail, // email của người dùng hiện tại
            'username': Display, // Tên của người dùng hiện tại
            'profile_image': currentProfileImage, // Ảnh đại diện của người dùng hiện tại
          }
        ])
      });

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

      String currentUserUid = currentUser.uid ;

      // Xóa yêu cầu kết bạn khỏi FriendRequests
      await FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(currentUserUid)
          .update({
        'requests': FieldValue.arrayRemove([friendRequest])
      });

      debugPrint('Đã xóa yêu cầu kết bạn.');
    } catch (e) {
      debugPrint('Lỗi khi xóa yêu cầu kết bạn: $e');
    }
  }
}
