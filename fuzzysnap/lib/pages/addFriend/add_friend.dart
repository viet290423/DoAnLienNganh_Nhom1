import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendService {
  // Gửi yêu cầu kết bạn
  Future<void> sendFriendRequest(String recipientEmail) async {
    try {
      // Lấy thông tin người dùng hiện tại (người gửi yêu cầu kết bạn)
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('Người dùng hiện tại không tồn tại.');
        return;
      }

      String currentUserEmail = currentUser.email ?? '';
      
      // Tìm kiếm thông tin của người gửi trong collection 'User'
      DocumentSnapshot<Map<String, dynamic>> senderDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUserEmail)
          .get();

      // Kiểm tra nếu dữ liệu của người gửi tồn tại
      if (!senderDoc.exists) {
        debugPrint('Không tìm thấy thông tin người dùng hiện tại.');
        return;
      }

      // Lấy các thông tin của người gửi
      Map<String, dynamic>? senderData = senderDoc.data();
      String senderUsername = senderData?['username'] ?? 'Unknown';
      String senderProfileImage = senderData?['profile_image'] ?? 'default_profile_image_url';
      String senderEmail = senderData?['email'] ?? '';
      Timestamp requestTime = Timestamp.now(); // Lấy thời gian gửi yêu cầu

      // Tạo map chứa thông tin người gửi
      Map<String, dynamic> senderInfo = {
        'username': senderUsername,
        'email': senderEmail,
        'profile_image': senderProfileImage,
        'time': requestTime
      };

      // Truy cập vào collection FriendRequests của người nhận (theo email)
      DocumentReference recipientDoc = FirebaseFirestore.instance
          .collection('FriendRequests')
          .doc(recipientEmail);

      // Cập nhật hoặc thêm mới yêu cầu kết bạn vào mảng yêu cầu kết bạn của người nhận
      await recipientDoc.update({
        'requests': FieldValue.arrayUnion([senderInfo]) // Thêm thông tin người gửi vào mảng 'requests'
      }).catchError((error) async {
        // Nếu doc của người nhận chưa tồn tại, tạo mới
        await recipientDoc.set({
          'requests': [senderInfo]
        });
      });

      debugPrint('Yêu cầu kết bạn đã được gửi thành công.');
    } catch (e) {
      debugPrint('Lỗi khi gửi yêu cầu kết bạn: $e');
    }
  }
}
