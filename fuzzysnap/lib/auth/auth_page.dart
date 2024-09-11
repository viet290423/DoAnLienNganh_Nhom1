import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/auth/login_or_register_page.dart';
import 'package:fuzzysnap/pages/main_page.dart';

class AuthPage extends StatelessWidget {
  final List<CameraDescription> cameras; // Thêm biến cameras

  const AuthPage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainPage(cameras: cameras); // Truyền cameras vào MainPage
          } else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
