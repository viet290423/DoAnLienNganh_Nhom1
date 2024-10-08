import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/setting/change_password_page.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  File? _selectedImage;
  bool _isLoading = false;

  // Controller để quản lý TextField của username
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load dữ liệu người dùng khi khởi tạo
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

  // Hàm để lưu username mới lên Firestore
  Future<void> _saveChanges() async {
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection("User")
            .doc(currentUser!.email)
            .update({'username': _usernameController.text});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật tên người dùng thành công')),
        );
      } catch (e) {
        print("Error saving username: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi cập nhật tên người dùng')),
        );
      }
    }
  }

  // Lấy thông tin người dùng từ Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: IconButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
        }, icon: const Icon(Icons.settings),

        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();

            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundImage: user?['profile_image'] != null
                              ? NetworkImage(user!['profile_image'])
                              : _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : null,
                          child: _selectedImage == null &&
                                  user?['profile_image'] == null
                              ? const Icon(Icons.person, size: 100)
                              : null,
                        ),
                        if (_isLoading) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Thêm TextField để thay đổi username
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?['email'] ?? 'Email not available',
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text('Lưu thay đổi',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }
}
