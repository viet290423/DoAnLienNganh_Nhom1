import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuzzysnap/service/comment_service.dart';
import 'package:intl/intl.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId; // postId của bài viết
  final String postUserEmail; // Email của người tạo bài viết
  final String postUserName;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.postUserEmail,
    required this.postUserName,
  });

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  final User? user =
      FirebaseAuth.instance.currentUser; // Lấy thông tin người dùng hiện tại
  List<dynamic>? userFriends; // Danh sách bạn bè của người dùng hiện tại

  final List<String> _emojiList = [
    '🍎',
    '🍌',
    '🥕',
    '🍩',
    '🥚',
    '🍟',
    '🍇',
    '🥑',
    '🍦',
    '🥝',
    '🍪',
    '🍋',
    '🍈',
    '🍉',
    '🍊',
    '🍍',
    '🥒',
    '🍓',
    '🍠',
    '🍇',
    '🍉',
    '🍒',
    '🍔',
    '🍕',
    '🍞',
    '🥭',
    '🍫',
    '🍯',
    '🍑',
    '🍏',
    '🍑',
    '🍆',
    '🥥',
    '🍅',
    '🍡',
    '🍙',
    '🍘',
    '🍨',
    '🍮',
    '🍧'
  ];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Lấy danh sách bạn bè của người dùng hiện tại khi khởi tạo
    _loadUserFriends();
  }

  Future<void> _loadUserFriends() async {
    if (user != null) {
      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user!.email)
          .get();

      setState(() {
        Map<String, dynamic>? userData =
            currentUserDoc.data() as Map<String, dynamic>?;
        userFriends = userData?['listFriend'] ?? [];
      });
    }
  }

  // Kiểm tra xem người bình luận có là bạn với người dùng hiện tại không
  bool _isFriendWithCommenter(String commenterEmail) {
    if (userFriends == null) return false;
    return userFriends!.any((friend) => friend['email'] == commenterEmail);
  }

  // Function to encrypt text to random emojis
  String encryptCommentToEmoji(String text) {
    return text.split('').map((char) {
      return _getRandomEmoji(); // Get a random emoji for each character
    }).join('');
  }

  // Function to get a random emoji from the list
  String _getRandomEmoji() {
    return _emojiList[_random.nextInt(_emojiList.length)];
  }

  // Định dạng thời gian
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: MediaQuery.of(context).viewInsets,
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                height: 5.0,
                width: 50.0,
                color: Colors.grey[300],
                margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: _commentService.getCommentsStream(
                      widget.postId, widget.postUserEmail),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<DocumentSnapshot> comments = snapshot.data!;

                    if (comments.isEmpty) {
                      return const Center(
                          child: Text('No comments yet. Be the first!'));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        var commentData =
                            comments[index].data() as Map<String, dynamic>;
                        String commenterEmail = commentData['UserEmail'];

                        // Luôn hiển thị bình luận gốc của người dùng hiện tại
                        if (commenterEmail == user?.email) {
                          return _buildCommentTile(
                              commentData, commentData['CommentText']);
                        }

                        // Kiểm tra mối quan hệ bạn bè với người bình luận
                        bool isFriend = _isFriendWithCommenter(commenterEmail);

                        // Hiển thị bình luận dạng mã hóa nếu không phải bạn bè
                        String displayedComment = isFriend
                            ? commentData['CommentText']
                            : encryptCommentToEmoji(commentData['CommentText']);

                        return _buildCommentTile(commentData, displayedComment);
                      },
                    );
                  },
                ),
              ),
              // const Divider(height: 1.0),
              _buildCommentInput(),
            ],
          );
        },
      ),
    );
  }

  // Hàm để xây dựng widget bình luận
  Widget _buildCommentTile(
      Map<String, dynamic> commentData, String displayedComment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(commentData['AvatarUrl']),
      ),
      title: Text(
        commentData['UserName'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(displayedComment),
      trailing: Text(
        _formatTimestamp(commentData['CommentTime']),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  // Form nhập bình luận
  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: Theme.of(context).colorScheme.onSecondary,
              controller: _commentController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                labelText: 'Add a comment...',
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                prefixIcon: const Icon(CupertinoIcons.chat_bubble),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              size: 30,
            ),
            onPressed: () {
              if (_commentController.text.trim().isNotEmpty) {
                _commentService.addComment(
                  widget.postId,
                  widget.postUserEmail,
                  _commentController.text.trim(),
                );
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
