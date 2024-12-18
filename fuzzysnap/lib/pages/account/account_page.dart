import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/account/friend_list_account.dart';
import 'package:fuzzysnap/pages/home_page.dart';
import 'package:fuzzysnap/pages/main_page.dart';
import 'package:fuzzysnap/pages/setting/setting_page.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class AccountPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const AccountPage({super.key, required this.cameras});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int friendCount = 0;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  File? _selectedImage;
  bool _isLoading = false;

  // Controller để quản lý TextField của username
  final TextEditingController _usernameController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load dữ liệu người dùng khi khởi tạo
    _loadFriendCount(); // Load số lượng bạn bè khi khởi tạo
  }

  // Hàm để tải dữ liệu người dùng từ Firestore và gán vào TextEditingController
  Future<void> _loadUserData() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("User")
          .doc(currentUser!.email)
          .get();
      final userData = userDoc.data();
      if (userData != null) {
        _usernameController.text = userData['username'] ?? '';
      }
    }
  }

  // Hàm để tải số lượng bạn bè từ Firestore
  Future<void> _loadFriendCount() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser!.email)
          .get();

      if (userDoc.exists) {
        List<dynamic> friends = userDoc.data()?['listFriend'] ?? [];
        setState(() {
          friendCount = friends.length; // Cập nhật số lượng bạn bè
        });
      }
    }
  }

  // Hàm để chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isLoading = true;
      });
      await _replaceImageInStorage();
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm để xóa ảnh cũ và tải ảnh mới lên Firebase Storage
  Future<void> _replaceImageInStorage() async {
    if (_selectedImage == null || currentUser == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('${currentUser!.email}.jpg');

      // Xóa ảnh cũ nếu tồn tại
      final userDoc = await FirebaseFirestore.instance
          .collection("User")
          .doc(currentUser!.email)
          .get();
      if (userDoc.exists && userDoc.data()?['profile_image'] != null) {
        final oldImageUrl = userDoc.data()!['profile_image'] as String;
        final oldRef = FirebaseStorage.instance.refFromURL(oldImageUrl);
        await oldRef.delete();
      }

      // Tải ảnh mới lên
      await ref.putFile(_selectedImage!);
      String avatarUrl = await ref.getDownloadURL();

      // Cập nhật URL ảnh avatar trong Firestore
      await FirebaseFirestore.instance
          .collection("User")
          .doc(currentUser!.email)
          .update({'profile_image': avatarUrl});
    } catch (e) {
      print("Error replacing image: $e");
    }
  }

  // Lấy thông tin người dùng từ Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(currentUser!.email)
        .get();
  }

  // hàm đếm số bài đăng của người dùng
  Future<int> _getPostCount() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('UserPosts')
          .doc(currentUser!.email)
          .collection('Posts')
          .get(); // Query the subcollection for the user's posts
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
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              return Column(
                children: [
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundImage: user?['profile_image'] != null
                                  ? NetworkImage(user!['profile_image'])
                                  : _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : null,
                              child: _selectedImage == null &&
                                      user?['profile_image'] == null
                                  ? Icon(
                                      Icons.person,
                                      size: 100,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    )
                                  : null,
                            ),
                            if (_isLoading) const CircularProgressIndicator(),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage, // Hàm để chọn ảnh
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          user?['username'] ?? 'No Username',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.setting_2),
                          iconSize: 40,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SettingPage()));
                          },
                        ),
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
                            const Text('Post', style: TextStyle(fontSize: 20)),
                            FutureBuilder<int>(
                              future:
                                  _getPostCount(), // Call the method to get the post count
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                return Text(
                                  '${snapshot.data ?? 0}', // Display the post count
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
                            GestureDetector(
                              onTap: () {
                                // Điều hướng đến trang FriendListPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FriendListPage()),
                                );
                              },
                              child: Column(
                                children: [
                                  const Text('Friends',
                                      style: TextStyle(fontSize: 20)),
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
                          .doc(currentUser!.email)
                          .collection('Posts')
                          .orderBy('TimeStamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
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
                              var postId = post['PostId'];
                              var imageUrl = post[
                                  'ImageUrl']; // Assuming each post has an 'ImageUrl'
                              return GestureDetector(
                                onTap: () {
                                  // Handle post click if needed
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainPage(
                                        selectedPostId:
                                            postId, cameras: widget.cameras, 
                                      ),
                                    ),
                                  );
                                  print("Post ID: $postId");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xFF6D9886), width: 3.0),
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
          }),
    );
  }
}
