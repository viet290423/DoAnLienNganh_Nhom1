import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/chat/chat_page.dart';

class FriendAccountPage extends StatefulWidget {
  final String friendEmail;

  const FriendAccountPage({super.key, required this.friendEmail});

  @override
  _FriendAccountPageState createState() => _FriendAccountPageState();
}

class _FriendAccountPageState extends State<FriendAccountPage> {
  int friendCount = 0;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriendCount();
  }

  // Hàm để tải dữ liệu của người bạn từ Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> _getFriendDetails() async {
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(widget.friendEmail) // Sử dụng email của người bạn
        .get();
  }

  // Hàm để tải số lượng bạn bè của người bạn từ Firestore
  Future<void> _loadFriendCount() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.friendEmail)
        .get();

    if (userDoc.exists) {
      List<dynamic> friends = userDoc.data()?['listFriend'] ?? [];
      setState(() {
        friendCount = friends.length;
      });
    }
  }

  // Hàm để lấy số bài đăng của người bạn
  Future<int> _getPostCount() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('UserPosts')
          .doc(widget.friendEmail) // Sử dụng email của người bạn
          .collection('Posts')
          .get();
      return querySnapshot.size;
    } catch (e) {
      print("Error getting post count: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getFriendDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            Map<String, dynamic>? friendData = snapshot.data!.data();
            return Column(
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            CupertinoIcons.back,
                            size: 40,
                          )),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                friendData?['profile_image'] != null
                                    ? NetworkImage(friendData!['profile_image'])
                                    : null,
                            child: friendData?['profile_image'] == null
                                ? const Icon(Icons.person, size: 100)
                                : null,
                          ),
                          Text(
                            friendData?['username'] ?? 'No Username',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        color: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (value) async {
                          if (value == 'Remove') {
                            print("Remove friend");
                          } else if (value == 'Message') {
                            // Lấy thông tin của người bạn từ Firestore
                            final friendDoc = await FirebaseFirestore.instance
                                .collection('User')
                                .doc(widget.friendEmail)
                                .get();

                            if (friendDoc.exists) {
                              // Tạo một map friendData chứa thông tin người bạn
                              Map<String, dynamic> friendData = {
                                'username': friendDoc.data()?['username'] ??
                                    'No Username',
                                'email': widget.friendEmail,
                                'uid': friendDoc.data()?['uid'],
                                'profile_image':
                                    friendDoc.data()?['profile_image'] ??
                                        'default_profile_image_url',
                              };

                              // Điều hướng đến ChatPage với thông tin friendData
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    friendData: friendData,
                                    chatBoxId: '',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'Remove',
                            child: Row(
                              children: [
                                Icon(
                                    CupertinoIcons
                                        .person_crop_circle_badge_xmark,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                const SizedBox(width: 10),
                                const Text(
                                  'Remove friend',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Message',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.chat_bubble,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                const SizedBox(width: 10),
                                const Text(
                                  'Message',
                                  style: TextStyle(
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
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('Posts', style: TextStyle(fontSize: 20)),
                          FutureBuilder<int>(
                            future: _getPostCount(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              return Text(
                                '${snapshot.data ?? 0}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6D9886),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Friends', style: TextStyle(fontSize: 20)),
                          Text(
                            '$friendCount',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6D9886),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('UserPosts')
                        .doc(widget.friendEmail)
                        .collection('Posts')
                        .orderBy('TimeStamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No posts yet"));
                      }

                      var posts = snapshot.data!.docs;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            var post = posts[index];
                            var imageUrl = post['ImageUrl'];

                            return GestureDetector(
                              onTap: () {
                                // Handle post click if needed
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }
}
