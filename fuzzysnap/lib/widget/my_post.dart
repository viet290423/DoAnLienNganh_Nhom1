import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/app/dimensions.dart';
import 'package:fuzzysnap/widget/like_button.dart';
import 'package:intl/intl.dart';

class MyPost extends StatefulWidget {
  final String title;
  final String userEmail;
  final String userName;
  final Timestamp timestamp;
  final String imageUrl;
  final String postId;

  const MyPost({
    super.key,
    required this.title,
    required this.userEmail,
    required this.userName,
    required this.timestamp,
    required this.imageUrl,
    required this.postId,
  });

  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ValueNotifier<bool> _isFavoriteNotifier = ValueNotifier<bool>(false);
  final List<Offset> _heartPositions = [];

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Convert Timestamp to DateTime and format it
    DateTime dateTime = widget.timestamp.toDate();
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("User")
          .doc(widget.userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          Map<String, dynamic>? user = snapshot.data!.data();
          return _buildPostContent(context, user, formattedTime);
        } else {
          return const Text("No data");
        }
      },
    );
  }

  Widget _buildPostContent(
      BuildContext context, Map<String, dynamic>? user, String formattedTime) {
    void _removePost() async {
      try {
        await FirebaseFirestore.instance
            .collection('Posts')
            .doc(widget.postId) // Xóa dựa trên postId
            .delete();

        // Hiển thị thông báo thành công hoặc điều hướng sau khi xóa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post removed successfully')),
        );
      } catch (e) {
        print('Error removing post: $e');
        // Hiển thị thông báo lỗi nếu có
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Error removing post')),
        // );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              spreadRadius: 3,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            top: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: user?['profile_image'] != null
                                ? NetworkImage(user!['profile_image'])
                                : null,
                            child: user?['profile_image'] == null
                                ? const Icon(Icons.person, size: 32)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            // height: 24,
                            child: Text(
                              widget.userName,
                              style: const TextStyle(
                                // color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            // height: 20,
                            child: Text(
                              formattedTime, // Display the formatted timestamp here
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    color: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (value) {
                      if (value == 'Edit') {
                        // Xử lý khi chọn Edit (điều hướng tới trang chỉnh sửa chẳng hạn)
                        print("Edit selected");
                      } else if (value == 'Remove') {
                        // Xử lý khi chọn Remove (xóa bài post)
                        _removePost(); // Gọi hàm để xóa post
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              'Edit',
                              style: TextStyle(
                                // color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Text(
                              'Remove',
                              style: TextStyle(
                                // color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                  )
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onDoubleTap: () {
                  _isFavoriteNotifier.value = !_isFavoriteNotifier.value;
                },
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    // color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LikeButton(
                    isFavoriteNotifier: _isFavoriteNotifier,
                    onFavoriteChanged: (newValue) {
                      // Cập nhật trạng thái yêu thích ở đây
                      // Bạn có thể thêm logic lưu vào Firestore hoặc các hành động khác
                    },
                  ),
                  _buildCommentButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentButton() {
    return IconButton(
      icon: Icon(
        CupertinoIcons.chat_bubble,
        color: Theme.of(context).colorScheme.onSecondary,
        size: 30,
        // weight: 100,
      ),
      onPressed: () {
        print("Commented");
      },
    );
  }
}
