import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy chatBoxId giữa hai người dùng dựa trên UID của họ
  Future<String> getChatBoxId(String userUid, String friendUid) async {
    try {
      // Tạo ID duy nhất cho hộp chat bằng cách ghép 2 UID theo thứ tự từ nhỏ đến lớn
      List<String> uids = [userUid, friendUid];
      uids.sort();
      String chatBoxId = uids.join('_');
      debugPrint('chatBoxId: $chatBoxId');

      // Kiểm tra xem hộp chat đã tồn tại chưa
      DocumentSnapshot chatBoxDoc =
          await _firestore.collection('chatBox').doc(chatBoxId).get();

      if (chatBoxDoc.exists) {
        return chatBoxId; // Trả về chatBoxId nếu hộp chat đã tồn tại
      } else {
        // Nếu hộp chat chưa tồn tại, tạo hộp chat mới với thông tin ban đầu
        await _firestore.collection('chatBox').doc(chatBoxId).set({
          'userUid': userUid,
          'friendUid': friendUid,
          'messages': [], // Ban đầu chưa có tin nhắn
          'lastMessage': '', // Thêm trường lastMessage
          'lastMessageTime':
              FieldValue.serverTimestamp(), // Thêm trường lastMessageTime
        });
        return chatBoxId;
      }
    } catch (e) {
      print('Lỗi khi lấy chatBoxId: $e');
      throw Exception('Không thể lấy chatBoxId'); // Ném lại lỗi
    }
  }

  // Gửi tin nhắn giữa hai người dùng
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

      // Tạo đối tượng tin nhắn mới
      Map<String, dynamic> newMessage = {
        'message': message,
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'senderUsername': senderUsername,
        'receiverUsername': receiverUsername,
        'createdAt': timestamp, // Thêm thời gian tạo
      };

      // Thêm tin nhắn vào hộp chat
      await _firestore.collection('chatBox').doc(chatBoxId).update({
        'messages': FieldValue.arrayUnion([newMessage]),
        'lastMessage': message, // Cập nhật lastMessage
        'lastMessageTime': timestamp, // Cập nhật lastMessageTime
        'idChat': chatBoxId,
      });

      print('Tin nhắn đã được gửi thành công.');
    } catch (e) {
      print('Lỗi khi gửi tin nhắn: $e');
      throw Exception('Không thể gửi tin nhắn'); // Ném lại lỗi
    }
  }

  // Lấy danh sách tin nhắn từ hộp chat
  Stream<DocumentSnapshot> getChatMessages(String chatBoxId) {
    return _firestore.collection('chatBox').doc(chatBoxId).snapshots();
  }
}
