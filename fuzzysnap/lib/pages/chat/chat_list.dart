import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/chat/ai_chat_page.dart';
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
  final Map<String, Map<String, dynamic>> friendDataCache = {};

  final Map<String, dynamic> chatBotData = {
    'username': 'ChatBot',
    'profile_image':
        'assets/images/chatbot_logo.png', // Hình ảnh đại diện của ChatBot
    'lastMessage': 'Start chatting with AI',
    'lastMessageTime': DateTime.now(), // Thời gian tin nhắn cuối
    'unreadMessages': 0,
  };

  @override
  void initState() {
    super.initState();
    currentUserUid = _auth.currentUser!.uid; // Lấy UID của người dùng hiện tại
  }

  @override
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
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải dữ liệu'));
          }

          final chatBoxes = snapshot.data!.docs;

          // Lọc ra các chat box của người dùng hiện tại
          final currentUserChatBoxes = chatBoxes.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String senderUid = data['userUid'];
            final String receiverUid = data['friendUid'];
            return senderUid == currentUserUid || receiverUid == currentUserUid;
          }).toList();

          // Chèn ChatBot vào danh sách
          final List<Map<String, dynamic>> combinedChatList = [
            chatBotData, // ChatBot luôn ở trên đầu
            ...currentUserChatBoxes.map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                })
          ];

          if (combinedChatList.isEmpty) {
            return const Center(child: Text('Không có cuộc trò chuyện nào.'));
          }

          return ListView.builder(
            itemCount: combinedChatList.length,
            itemBuilder: (context, index) {
              final chatBoxData = combinedChatList[index];

              // Kiểm tra nếu là ChatBot
              if (chatBoxData == chatBotData) {
                return _buildChatBotTile();
              }

              final String senderUid = chatBoxData['userUid'];
              final String receiverUid = chatBoxData['friendUid'];
              final String chatBoxId = chatBoxData['id'];
              final String friendUid =
                  (senderUid == currentUserUid) ? receiverUid : senderUid;

              // Kiểm tra cache
              if (friendDataCache.containsKey(friendUid)) {
                return _buildChatTile(
                  friendDataCache[friendUid]!,
                  chatBoxData,
                  chatBoxId,
                );
              }

              // Nếu chưa có, tải dữ liệu bạn bè
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
                      as Map<String, dynamic>;
                  friendDataCache[friendUid] = friendData; // Lưu vào cache

                  return _buildChatTile(friendData, chatBoxData, chatBoxId);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Hàm xây dựng widget ChatTile
  Widget _buildChatTile(
    Map<String, dynamic> friendData,
    Map<String, dynamic> chatBoxData,
    String chatBoxId,
  ) {
    final String username = friendData['username'] ?? 'Không có tên';
    final String profileImage = friendData['profile_image'] ?? '';
    final String lastMessage = chatBoxData['lastMessage'] ?? '';
    final Timestamp? lastMessageTime = chatBoxData['lastMessageTime'];
    final unreadCount = chatBoxData['unreadMessages']?[currentUserUid] ?? 0;

    // Format thời gian
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
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: profileImage.isNotEmpty
                ? NetworkImage(profileImage)
                : const NetworkImage(
                    'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg'),
          ),
          if (unreadCount > 0) // Hiển thị chấm đỏ nếu có tin nhắn chưa đọc
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        username,
        style: TextStyle(
          fontSize: 18,
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
          color: unreadCount > 0
              ? Theme.of(context).colorScheme.onSecondary
              : const Color.fromARGB(255, 86, 86, 86),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeString,
            style: const TextStyle(fontSize: 12),
          ),
          if (unreadCount > 0) // Hiển thị số tin nhắn chưa đọc
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      onTap: () async {
        await _firestore.collection('chatBox').doc(chatBoxId).update({
          'unreadMessages.$currentUserUid': 0, // Đặt lại tin nhắn chưa đọc
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
  }

  Widget _buildChatBotTile() {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage(chatBotData['profile_image']),
      ),
      title: Text(
        chatBotData['username'],
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        chatBotData['lastMessage'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIChatDetailScreen(
              userName: chatBotData['username'],
              userImage: chatBotData['profile_image'],
            ),
          ),
        );
      },
    );
  }
}
