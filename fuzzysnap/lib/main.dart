import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuzzysnap/auth/auth_page.dart';
import 'package:fuzzysnap/auth/login_or_register_page.dart';
import 'package:fuzzysnap/firebase_options.dart';
import 'package:fuzzysnap/pages/add_post/camera_page.dart';
import 'package:fuzzysnap/pages/chat/chat_page.dart';
import 'package:fuzzysnap/pages/home_page.dart';
import 'package:fuzzysnap/pages/main_page.dart';
import 'package:fuzzysnap/pages/notification_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(cameras: cameras),
      routes: {
        '/login_register_page': (context) => const LoginOrRegisterPage(),
        '/main_page' : (context) => MainPage(cameras: cameras,),
        '/home_page' : (context) => HomePage(),
        '/notification_page' : (context) => NotificationPage(),
        '/camera_page' : (context) => CameraPage(cameras: cameras,),
        '/chat_page' : (context) => const ChatPage(),
      }, 
    );
  }
}
