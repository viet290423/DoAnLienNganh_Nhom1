import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/setting/change_infor.dart';
import 'package:fuzzysnap/pages/setting/change_password_page.dart';
import 'package:fuzzysnap/provider/provider.dart';
import 'package:fuzzysnap/widget/setting_widget.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${error.toString()}')),
      );
    });
  }

  // bool isDarkMode = false;
  bool isNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        forceMaterialTransparency: true,
        // backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'SETTING',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UiProvider>(
            builder: (context, UiProvider notifier, child) {
          return Column(
            children: [
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'Account',
                children: [
                  buildSettingItem('Information', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangeInformation()),
                    );
                  }, textColor: Theme.of(context).colorScheme.onSecondary),
                  buildSettingItem('Change Password', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage()),
                    );
                  }, textColor: Theme.of(context).colorScheme.onSecondary),
                ],
              ),
              const SizedBox(height: 20),
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'General',
                children: [
                  buildSettingItem(
                    'Language',
                    trailing: const Text('English'),
                    onTap: () {},
                    textColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  buildSettingItem(
                    'Dark Mode',
                    trailing: Switch(
                        activeColor: Colors.deepPurple,
                        value: notifier.isDark,
                        onChanged: (value) => notifier.changeTheme()),
                    onTap: () {},
                    textColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  buildSettingItem(
                    'Notification',
                    trailing: Switch(
                      activeColor: Colors.deepPurple,
                      value: isNotification,
                      onChanged: (bool value) {
                        setState(() {
                          isNotification = value;
                        });
                      },
                    ),
                    onTap: () {},
                    textColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'About us',
                children: [
                  buildSettingItem('Website',
                      onTap: () {},
                      textColor: Theme.of(context).colorScheme.onSecondary),
                  buildSettingItem('Help',
                      onTap: () {},
                      textColor: Theme.of(context).colorScheme.onSecondary),
                ],
              ),
              const SizedBox(height: 20),
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'Red Zone',
                children: [
                  buildSettingItem(
                    'Log out',
                    trailing: const Icon(Icons.logout),
                    onTap: () {
                      signUserOut(context);
                    },
                    textColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  buildSettingItem(
                    'Delete account',
                    textColor: Colors.red,
                    onTap: () {
                      showDeleteAccountDialog(context);
                    },
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Do you really want to delete your account?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showPasswordConfirmationDialog(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

// Hàm hiển thị hộp thoại yêu cầu nhập lại mật khẩu
  void _showPasswordConfirmationDialog(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String password = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Confirm Password to Delete Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: TextField(
            onChanged: (value) {
              password = value;
            },
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter your password',
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Đóng dialog
                  await _deleteAccount(password, scaffoldMessenger, context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Hàm thực hiện xóa tài khoản khi đã nhập mật khẩu
  Future<void> _deleteAccount(String password,
      ScaffoldMessengerState scaffoldMessenger, BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && password.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        // Xác thực lại người dùng
        await user.reauthenticateWithCredential(credential);

        // Xóa tài liệu người dùng trên Firestore
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.email)
            .delete();

        // Xóa tài khoản Firebase
        await user.delete();
        await FirebaseAuth.instance.signOut();

        // Hiển thị thông báo thành công
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );

        // Chờ 1 giây trước khi điều hướng
        await Future.delayed(const Duration(seconds: 1));

        // Kiểm tra nếu widget vẫn còn mounted trước khi điều hướng
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text("Password is required to delete account.")),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Failed to delete account: $e")),
      );
    }
  }
}
