import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzysnap/pages/chat/chat_image_full_screen.dart';
import 'package:fuzzysnap/service/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> friendData;
  const ChatPage(
      {super.key, required this.friendData, required String chatBoxId});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? chatBoxId;
  String? userUid;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker(); // Thêm ImagePicker

  @override
  void initState() {
    super.initState();
    _initializeChatBox();
    WidgetsBinding.instance.addObserver(
        this); // Đăng ký observer để theo dõi các thay đổi trong ứng dụng
    _focusNode
        .addListener(_handleFocusChange); // Lắng nghe sự thay đổi của FocusNode
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm xử lý thay đổi chiều cao bàn phím
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scrollToBottom();
  }

  // Hàm xử lý sự kiện khi `TextField` được focus
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _scrollToBottom();
    }
  }

  // Hàm khởi tạo hộp chat
  Future<void> _initializeChatBox() async {
    if (currentUser != null) {
      String currentUserEmail = currentUser!.email ?? '';
      DocumentSnapshot<Map<String, dynamic>> senderDoc = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(currentUserEmail)
          .get();
      if (senderDoc.exists && senderDoc.data() != null) {
        userUid = senderDoc.data()!['uid'];
      }
      debugPrint("UID của người dùng: $userUid");
      if (widget.friendData.containsKey('uid')) {
        String friendUid = widget.friendData['uid'];
        debugPrint("UID của bạn bè: $friendUid");
        chatBoxId = await _chatService.getChatBoxId(userUid!, friendUid);
        setState(() {
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
      String message = messageController.text.trim();
      String senderUid = userUid!;
      String receiverUid = widget.friendData['uid'];
      String senderUsername = currentUser!.email ?? 'Người dùng';
      String receiverUsername = widget.friendData['username'] ?? 'Bạn';

      _chatService.sendMessage(
        chatBoxId: chatBoxId!,
        senderUid: senderUid,
        receiverUid: receiverUid,
        senderUsername: senderUsername,
        receiverUsername: receiverUsername,
        message: message,
        imageUrl: "",
      );
      messageController.clear();
      _scrollToBottom();
    }
  }

  // Hàm gửi ảnh
  Future<void> _sendImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('chat_images/$fileName')
            .putFile(File(imagePath));
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();

        if (chatBoxId != null) {
          String senderUid = userUid!;
          String receiverUid = widget.friendData['uid'];
          String senderUsername = currentUser!.email ?? 'Người dùng';
          String receiverUsername = widget.friendData['username'] ?? 'Bạn';

          // Gửi tin nhắn với hình ảnh
          _chatService.sendMessage(
            chatBoxId: chatBoxId!,
            senderUid: senderUid,
            receiverUid: receiverUid,
            senderUsername: senderUsername,
            receiverUsername: receiverUsername,
            message: "", // Không có tin nhắn văn bản
            imageUrl: imageUrl,
          );
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Lỗi khi gửi ảnh: $e");
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
                widget.friendData['profile_image'] ?? '',
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
      body: Column(
        children: [
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
                      bool isImage = messageData['image'] != null ;

                      DateTime currentMessageTime =
                          messageData['createdAt'].toDate();
                      DateTime? previousMessageTime;

                      if (index > 0) {
                        previousMessageTime =
                            messages[index - 1]['createdAt'].toDate();
                      }

                      bool showAvatar = !isSentByMe &&
                          (index == messages.length - 1 ||
                              messages[index + 1]['senderUid'] !=
                                  messageData['senderUid']);
                      
                      return Column(
                        children: [
                          if (previousMessageTime == null ||
                              currentMessageTime
                                      .difference(previousMessageTime)
                                      .inMinutes >=
                                  1)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _formatTimestamp(currentMessageTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: isSentByMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (showAvatar) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                      widget.friendData['profile_image'] ?? '',
                                    ),
                                  ),
                                ),
                              ],
                              if (!isSentByMe && !showAvatar) ...[
                                const SizedBox(width: 40),
                              ],
                              if (isImage)
                                GestureDetector(
                                  onTap: () {
                                    /// Mở ảnh toàn màn hình trong hộp thoại
                                    showDialog(
                                      context: context,
                                      builder: (context) => FullScreenImageDialog(imageUrl: messageData['image'] ?? ''),
                                    );
                                  },

                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            messageData['image'] ?? ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              else ...[
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
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _sendImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.photo,
                        color: Colors.blueAccent,
                      ),
                      onPressed: _sendImage,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
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
                const SizedBox(width: 5),
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
                          color: Colors.blue.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_sharp,
                      color: Colors.white,
                      size: 24,
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

  // Hàm định dạng thời gian tin nhắn
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (now.difference(timestamp).inDays == 0) {
      return DateFormat.Hm().format(timestamp);
    } else if (now.difference(timestamp).inDays == 1) {
      return "Hôm qua, ${DateFormat.Hm().format(timestamp)}";
    } else {
      return DateFormat('dd/MM/yyyy, HH:mm').format(timestamp);
    }
  }
}
