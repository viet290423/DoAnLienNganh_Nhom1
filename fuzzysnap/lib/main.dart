// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuzzysnap/auth/auth_page.dart';
import 'package:fuzzysnap/auth/login_or_register_page.dart';
import 'package:fuzzysnap/firebase_options.dart';
import 'package:fuzzysnap/pages/home_page.dart';
// import 'firebase_options.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // final cameras = await availableCameras();

  // runApp(MyApp(cameras: cameras,));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // final List<CameraDescription> cameras;
  // const MyApp({super.key, required this.cameras});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  
      home: const AuthPage(),
      routes: {
        '/login_register_page': (context) => const LoginOrRegisterPage(),
        '/home_page' : (context) => const HomePage(),
        // '/camera_page' : (context) => CameraPage(cameras: cameras,),
        // '/profile_page' : (context) => ProfilePage(),
        // '/users_page' : (context) => const UsersPage(),
      },
    );
  }
}
