import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/account/friend_account_page.dart';

import 'package:fuzzysnap/pages/chat/chat_page.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  _FriendListPageState createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> friendsList = [];
  bool isLoading = true; // Biến để kiểm soát trạng thái tải dữ liệu
  String? errorMessage; // Biến để lưu lỗi (nếu có)

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _loadFriendsList();
    }
  }

  Future<void> _loadFriendsList() async {
    try {
      // Lấy thông tin người dùng hiện tại từ Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('User')
              .doc(currentUser!.email) // Sử dụng email làm ID của tài liệu
              .get();

      if (userDoc.exists) {
        List<dynamic> friends = userDoc.data()?['listFriend'] ?? [];
        setState(() {
          friendsList = friends.cast<Map<String, dynamic>>();
          isLoading = false; // Đã tải xong dữ liệu
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Không tìm thấy thông tin người dùng.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi khi lấy danh sách bạn bè: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Danh sách bạn bè')),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Hiển thị vòng xoay khi đang tải dữ liệu
          : errorMessage != null
              ? Center(child: Text(errorMessage!)) // Hiển thị lỗi nếu có
              : friendsList.isEmpty
                  ? const Center(child: Text('Chưa có bạn bè nào.'))
                  : ListView.builder(
                      itemCount: friendsList.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> friend = friendsList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                friend['profile_image'] ??
                                    'default_profile_image_url'),
                          ),
                          title: Text(friend['username']),
                          subtitle: Text(friend['email']),
                          trailing: IconButton(
                            icon: const Icon(CupertinoIcons.chat_bubble),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                          friendData: friend,
                                          chatBoxId: '',
                                        )),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FriendAccountPage(
                                        friendEmail: friend['email'])));
                          },
                        );
                      },
                    ),
    );
  }
}
