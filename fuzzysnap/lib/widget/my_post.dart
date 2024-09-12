import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/widget/like_button.dart';
import 'package:intl/intl.dart';

class MyPost extends StatefulWidget {
  final String title;
  final String userEmail;
  final String userName;
  final Timestamp timestamp;
  final String imageUrl;

  const MyPost({
    super.key,
    required this.title,
    required this.userEmail,
    required this.userName,
    required this.timestamp,
    required this.imageUrl,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: user?['profile_image'] != null
                        ? NetworkImage(user!['profile_image'])
                        : null,
                    child: user?['profile_image'] == null
                        ? const Icon(Icons.person, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        child: Text(
                          widget.userName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
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
              const SizedBox(height: 30),
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
                    color: Colors.black,
                    fontSize: 18,
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
      icon: const Icon(
        CupertinoIcons.chat_bubble,
        color: Colors.black,
        size: 30,
        // weight: 100,
      ),
      onPressed: () {
        print("Commented");
      },
    );
  }
}
