import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy `chatBoxId` giữa hai người dùng dựa trên UID của họ
  Future<String> getChatBoxId(String userUid, String friendUid) async {
    try {
      // Tạo ID duy nhất cho hộp chat
      List<String> uids = [userUid, friendUid];
      uids.sort();
      String chatBoxId = uids.join('_');
      debugPrint('ChatBox ID: $chatBoxId');

      // Kiểm tra xem hộp chat đã tồn tại chưa
      DocumentSnapshot chatBoxDoc =
          await _firestore.collection('chatBox').doc(chatBoxId).get();
      if (chatBoxDoc.exists) {
        return chatBoxId; // Trả về chatBoxId nếu tồn tại
      }

      // Nếu chưa tồn tại, tạo hộp chat mới với thông tin ban đầu
      await _firestore.collection('chatBox').doc(chatBoxId).set({
        'userUid': userUid,
        'friendUid': friendUid,
        'messages': [],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadMessages': {}, // Khởi tạo trạng thái chưa đọc
      });
      return chatBoxId;
    } catch (e) {
      debugPrint('Lỗi khi lấy chatBoxId: $e');
      throw Exception('Không thể lấy chatBoxId');
    }
  }

  /// Gửi tin nhắn giữa hai người dùng
  Future<void> sendMessage({
    required String chatBoxId,
    required String senderUid,
    required String receiverUid,
    required String senderUsername,
    required String receiverUsername,
    required String message,
  }) async {
    try {
      Timestamp timestamp = Timestamp.now(); // Thời gian gửi tin nhắn

      // Tạo tin nhắn mới
      Map<String, dynamic> newMessage = {
        'message': message,
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'senderUsername': senderUsername,
        'receiverUsername': receiverUsername,
        'createdAt': timestamp,
        'isRead': false, // Tin nhắn chưa được đọc
      };

      // Cập nhật hộp chat với tin nhắn mới và trạng thái chưa đọc
      await _firestore.collection('chatBox').doc(chatBoxId).update({
        'messages': FieldValue.arrayUnion([newMessage]),
        'lastMessage': message,
        'lastMessageTime': timestamp,
        'unreadMessages.$receiverUid': FieldValue.increment(1),
      });
      debugPrint('Tin nhắn đã gửi thành công.');
    } catch (e) {
      debugPrint('Lỗi khi gửi tin nhắn: $e');
      throw Exception('Không thể gửi tin nhắn');
    }
  }

  /// Đặt lại tin nhắn chưa đọc về 0
  Future<void> resetUnreadMessages({
    required String chatBoxId,
    required String userUid,
  }) async {
    try {
      await _firestore.collection('chatBox').doc(chatBoxId).update({
        'unreadMessages.$userUid': 0,
      });
      debugPrint('Đã đặt lại tin nhắn chưa đọc cho $userUid.');
    } catch (e) {
      debugPrint('Lỗi khi đặt lại tin nhắn chưa đọc: $e');
      throw Exception('Không thể đặt lại tin nhắn chưa đọc');
    }
  }

  /// Lấy danh sách tin nhắn từ hộp chat
  Stream<DocumentSnapshot> getChatMessages(String chatBoxId) {
    return _firestore.collection('chatBox').doc(chatBoxId).snapshots();
  }

  /// Lấy danh sách hộp chat của người dùng hiện tại
  Stream<QuerySnapshot> getUserChats(String userUid) {
    return _firestore
        .collection('chatBox')
        .where('userUid', isEqualTo: userUid)
        .snapshots();
  }

  /// Đánh dấu tin nhắn là đã đọc
  Future<void> markMessageAsRead({
    required String chatBoxId,
    required String messageId,
  }) async {
    try {
      await _firestore.collection('chatBox').doc(chatBoxId).update({
        'messages.$messageId.isRead': true,
      });
      debugPrint('Tin nhắn $messageId đã được đánh dấu là đã đọc.');
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu tin nhắn đã đọc: $e');
    }
  }
}
