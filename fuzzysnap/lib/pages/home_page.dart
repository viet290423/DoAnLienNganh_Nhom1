import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/database/firestore.dart';
import 'package:fuzzysnap/widget/my_post.dart';
import 'package:fuzzysnap/pages/search_friend_page.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  final String? selectedPostId; // Tham số nhận ID bài đăng được chọn

  const HomePage({super.key, this.selectedPostId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();
  late PageController _pageController; // Điều khiển PageView
  int _initialPageIndex = 0; // Index ban đầu của bài đăng

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Khởi tạo PageController
  }

  @override
  void dispose() {
    _pageController.dispose(); // Giải phóng PageController
    super.dispose();
  }

  // Tìm vị trí index của bài đăng có PostId trùng với selectedPostId
  int _getIndexForSelectedPost(
      List<DocumentSnapshot> posts, String selectedPostId) {
    return posts.indexWhere((post) =>
        (post.data() as Map<String, dynamic>)['PostId'] == selectedPostId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Iconsax.search_normal_1),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: FriendSearchDelegate(),
                );
              },
            ),
          )
        ],
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'FUZZYSNAP',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: database.getAllPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("An error occurred. Please try again later."),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("No posts.. Post something!"),
              ),
            );
          }

          final posts = snapshot.data!;

          // Xác định index của bài đăng cần hiển thị nếu có selectedPostId
          if (widget.selectedPostId != null) {
            int selectedIndex =
                _getIndexForSelectedPost(posts, widget.selectedPostId!);
            if (selectedIndex != -1 && _initialPageIndex == 0) {
              // Chỉ cuộn một lần
              _initialPageIndex = selectedIndex;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _pageController.jumpToPage(selectedIndex);
              });
            }
          }

          // Hiển thị danh sách bài đăng
          return PageView.builder(
            controller: _pageController, // Điều khiển cuộn
            scrollDirection: Axis.vertical,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;

              String imageUrl = post['ImageUrl'] ?? '';
              String message = post['PostMessage'] ?? 'No message';
              String userEmail = post['UserEmail'] ?? 'Unknown';
              String id = post['PostId'] ?? '';
              Timestamp timestamp = post['TimeStamp'] ?? Timestamp.now();

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .doc(userEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return ListTile(
                      title: Text(message),
                      subtitle: const Text('Error loading username'),
                    );
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.exists) {
                      Map<String, dynamic> userData = snapshot.data!.data()!;
                      String userName = userData['username'] ?? 'Unknown';

                      return MyPost(
                        title: message,
                        userEmail: userEmail,
                        userName: userName,
                        timestamp: timestamp,
                        imageUrl: imageUrl,
                        postId: id,
                      );
                    } else {
                      return ListTile(
                        title: Text(message),
                        subtitle: const Text('Username not found'),
                      );
                    }
                  } else {
                    return ListTile(
                      title: Text(message),
                      subtitle: const Text('Username not available'),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
