import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/widget/my_textfield.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  var auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser;

  // void signUserOut() {
  //   FirebaseAuth.instance.signOut();
  // }

  // Hàm thay đổi mật khẩu
  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {
    try {
      var email = currentUser!.email;

      // Xác thực lại người dùng với mật khẩu cũ
      var cred =
          EmailAuthProvider.credential(email: email!, password: oldPassword);
      await currentUser!.reauthenticateWithCredential(cred);

      // Cập nhật mật khẩu mới
      await currentUser!.updatePassword(newPassword);

      // Đăng xuất và quay về trang đăng nhập
      await auth.signOut();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Password changed successfully. Please login again.')),
      );
      // Đăng xuất và điều hướng về trang đăng nhập
      await auth.signOut();

      // Điều hướng về trang đăng nhập và xoá hết các trang trước đó
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/auth_page',
        (route) => false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  // Kiểm tra xem mật khẩu có trùng khớp hay không
  bool _isPasswordValid() {
    return _newPasswordController.text == _confirmPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Old Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
                controller: _oldPasswordController,
                hintText: 'Enter old password',
                obscureText: true),
            const SizedBox(height: 20),
            Text(
              'New Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
                controller: _newPasswordController,
                hintText: 'Enter new password',
                obscureText: true),
            const SizedBox(height: 20),
            Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm new password',
                obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_isPasswordValid()) {
                  // Gọi hàm changePassword nếu mật khẩu trùng khớp
                  await changePassword(
                    oldPassword: _oldPasswordController.text,
                    newPassword: _newPasswordController.text,
                  );
                } else {
                  // Hiển thị thông báo lỗi nếu mật khẩu không khớp
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                'Change Password',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
