import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzysnap/service/chat_service.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> friendData;
  const ChatPage(
      {super.key, required this.friendData, required String chatBoxId});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  String? chatBoxId;
  String? userUid;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _initializeChatBox();
  }

  // Hàm khởi tạo hộp chat
  Future<void> _initializeChatBox() async {
    if (currentUser != null) {
      String currentUserEmail = currentUser!.email ?? '';
      // Tìm kiếm thông tin của người gửi trong collection 'User'
      DocumentSnapshot<Map<String, dynamic>> senderDoc = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(currentUserEmail)
          .get();
      // Lấy uid của người dùng
      if (senderDoc.exists && senderDoc.data() != null) {
        userUid = senderDoc.data()!['uid']; // Lấy uid từ tài liệu
      }
      debugPrint("UID của người dùng: $userUid");
      // Kiểm tra friendData và lấy UID của bạn
      if (widget.friendData.containsKey('uid')) {
        String friendUid = widget.friendData['uid'];
        debugPrint("UID của bạn bè: $friendUid");
        // Lấy chatBoxId
        chatBoxId = await _chatService.getChatBoxId(userUid!, friendUid);
        setState(() {
          // Cuộn đến cuối khi hộp chat được khởi tạo
          _scrollToBottom();
        });
      } else {
        debugPrint("Không tìm thấy UID của bạn bè.");
      }
    }
  }

  // Hàm gửi tin nhắn
  void _sendMessage() {
    if (messageController.text.isNotEmpty && chatBoxId != null) {
      String message = messageController.text.trim(); // Loại bỏ khoảng trắng
      String senderUid = userUid!; // Sử dụng userUid đã lấy
      String receiverUid = widget.friendData['uid'];
      String senderUsername = currentUser!.email ?? 'Người dùng';
      String receiverUsername = widget.friendData['username'] ?? 'Bạn';
      // Gửi tin nhắn
      _chatService.sendMessage(
        chatBoxId: chatBoxId!,
        senderUid: senderUid,
        receiverUid: receiverUid,
        senderUsername: senderUsername,
        receiverUsername: receiverUsername,
        message: message,
      );
      // Xóa nội dung của TextField sau khi gửi
      messageController.clear();
      // Tự động cuộn đến tin nhắn mới nhất
      _scrollToBottom();
    }
  }

  // Hàm cuộn đến cuối danh sách tin nhắn
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    // Định dạng giờ và phút: "HH:mm"
    return "${timestamp.day.toString().padLeft(2, '0')}/"
        "${timestamp.month.toString().padLeft(2, '0')} "
        "${timestamp.hour.toString().padLeft(2, '0')}:"
        "${timestamp.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                widget.friendData['profile_image'] ??
                    'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                widget.friendData['username'] ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            iconSize: 26,
            onPressed: () {
              debugPrint("Gọi thoại");
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            iconSize: 26,
            onPressed: () {
              debugPrint("Gọi video");
            },
          ),
        ],
      ),
      // Danh sách tin nhắn sẽ được hiển thị ở đây
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: chatBoxId != null
                  ? _chatService.getChatMessages(chatBoxId!)
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  List<dynamic> messages = (snapshot.data!.data()
                          as Map<String, dynamic>)['messages'] ??
                      [];
                  // Cuộn đến tin nhắn cuối cùng khi danh sách tin nhắn thay đổi
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var messageData = messages[index];
                      bool isSentByMe = messageData['senderUid'] == userUid;

                      // Lấy thời gian tạo của tin nhắn hiện tại
                      DateTime currentMessageTime =
                          messageData['createdAt'].toDate();
                      DateTime? previousMessageTime;

                      // Nếu không phải là tin nhắn đầu tiên, lấy thời gian của tin nhắn trước đó
                      if (index > 0) {
                        previousMessageTime =
                            messages[index - 1]['createdAt'].toDate();
                      }

                      // Kiểm tra xem đây có phải là cuối nhóm tin nhắn từ đối phương không
                      bool showAvatar = !isSentByMe &&
                          (index == messages.length - 1 || // Tin nhắn cuối cùng
                              messages[index + 1]['senderUid'] !=
                                  messageData[
                                      'senderUid']); // Tin nhắn cuối của nhóm

                      return Column(
                        children: [
                          // Hiển thị thời gian ở giữa nếu cần
                          if (previousMessageTime == null ||
                              currentMessageTime
                                      .difference(previousMessageTime)
                                      .inMinutes >=
                                  1)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _formatTimestamp(
                                    currentMessageTime), // Hàm format timestamp
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // Tin nhắn
                          Row(
                            mainAxisAlignment: isSentByMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              // Nếu là tin nhắn cuối nhóm từ đối phương, hiển thị ảnh đại diện
                              if (showAvatar) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                      widget.friendData['profile_image'] ??
                                          'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
                                    ),
                                  ),
                                ),
                              ],
                              // Nếu là tin nhắn của đối phương, đặt ảnh đại diện sau tin nhắn
                              if (!isSentByMe && !showAvatar) ...[
                                const SizedBox(width: 40),
                              ],
                              // Tin nhắn của người gửi hoặc đối phương
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSentByMe
                                      ? Colors.blue[300]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  messageData['message'],
                                  style: TextStyle(
                                    color: isSentByMe
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
                return const Center(child: Text("Không có tin nhắn nào."));
              },
            ),
          ),
          // Phần nhập tin nhắn và nút gửi
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Icon ảnh với hiệu ứng nổi
                GestureDetector(
                  onTap: () {
                    // Hàm xử lý chọn ảnh
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.photo,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        // Hàm xử lý chọn ảnh
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // TextField với viền bo tròn và độ nổi
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      labelText: 'Type a message...',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                // Nút gửi với hiệu ứng nổi
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
