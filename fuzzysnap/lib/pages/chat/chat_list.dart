import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/chat/chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    currentUserUid = _auth.currentUser!.uid; // Lấy UID của người dùng hiện tại
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chatBox')
            .orderBy('lastMessageTime', descending: true) // Order by latest
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải dữ liệu'));
          }

          final chatBoxes = snapshot.data!.docs;

          final currentUserChatBoxes = chatBoxes.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String senderUid = data['userUid'];
            final String receiverUid = data['friendUid'];
            return senderUid == currentUserUid || receiverUid == currentUserUid;
          }).toList();

          if (currentUserChatBoxes.isEmpty) {
            return const Center(child: Text('Không có cuộc trò chuyện nào.'));
          }

          return ListView.builder(
            itemCount: currentUserChatBoxes.length,
            itemBuilder: (context, index) {
              final chatBoxData =
                  currentUserChatBoxes[index].data() as Map<String, dynamic>;
              final String senderUid = chatBoxData['userUid'];
              final String receiverUid = chatBoxData['friendUid'];
              final String chatBoxId = currentUserChatBoxes[index].id;
              final String friendUid =
                  (senderUid == currentUserUid) ? receiverUid : senderUid;

              return FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('User')
                    .where('uid', isEqualTo: friendUid)
                    .get(),
                builder: (context, friendSnapshot) {
                  if (friendSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const LinearProgressIndicator(minHeight: 1);
                  }
                  if (friendSnapshot.hasError ||
                      !friendSnapshot.hasData ||
                      friendSnapshot.data!.docs.isEmpty) {
                    return const ListTile(
                      title: Text('Lỗi khi lấy thông tin người dùng'),
                    );
                  }
                  final friendData = friendSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>?;

                  if (friendData == null) {
                    return const ListTile(
                      title: Text('Không tìm thấy thông tin người dùng'),
                    );
                  }

                  final String username =
                      friendData['username'] ?? 'Không có tên';
                  final String profileImage = friendData['profile_image'] ?? '';
                  final String lastMessage = chatBoxData['lastMessage'] ?? '';
                  final bool isReadByReceiver =
                      chatBoxData['isReadByReceiver'] ?? true;
                  final Timestamp? lastMessageTime =
                      chatBoxData['lastMessageTime'];

                  String timeString = '';
                  if (lastMessageTime != null) {
                    final DateTime dateTime = lastMessageTime.toDate();
                    final now = DateTime.now();
                    final diff = now.difference(dateTime);
                    if (diff.inMinutes < 60) {
                      timeString = '${diff.inMinutes} phút trước';
                    } else if (diff.inHours < 24) {
                      timeString = '${diff.inHours} giờ trước';
                    } else {
                      timeString =
                          '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute}';
                    }
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : const NetworkImage(
                              'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg'),
                    ),
                    title: Text(username),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isReadByReceiver
                            ? FontWeight.normal
                            : FontWeight.bold, // Unread indicator
                        color: isReadByReceiver ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: Column(
                      children: [
                        Text(timeString),
                        if (!isReadByReceiver)
                          const Icon(Icons.circle,
                              size: 8, color: Colors.red), // Red dot for unread
                      ],
                    ),
                    onTap: () async {
                      await _firestore
                          .collection('chatBox')
                          .doc(chatBoxId)
                          .update({
                        'isReadByReceiver': true,
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            friendData: friendData,
                            chatBoxId: chatBoxId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
