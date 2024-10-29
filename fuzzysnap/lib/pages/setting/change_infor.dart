import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/widget/my_textfield.dart';

class ChangeInformation extends StatefulWidget {
  const ChangeInformation({super.key});

  @override
  State<ChangeInformation> createState() => _ChangeInformationState();
}

class _ChangeInformationState extends State<ChangeInformation> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isEditing = false;
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
        centerTitle: true,
        title: const Text(
          'Change your username',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your username',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              readOnly: !_isEditing,
              style: const TextStyle(
                color: Colors.black, // Màu của văn bản nhập vào
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '',
                hintStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                filled: true,
                fillColor: const Color(0xFFF2E7D5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 18.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    // Lưu thay đổi
                    _saveChanges();
                  }
                  _isEditing = !_isEditing;
                });
              },
              icon: Icon(
                _isEditing ? Icons.save : Icons.edit,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: Text(
                _isEditing ? 'Save' : 'Edit',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
