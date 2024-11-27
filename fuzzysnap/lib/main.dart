import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fuzzysnap/auth/auth_page.dart';
import 'package:fuzzysnap/auth/login_or_register_page.dart';
import 'package:fuzzysnap/firebase_options.dart';
import 'package:fuzzysnap/pages/add_post/camera_page.dart';
import 'package:fuzzysnap/pages/chat/chat_list.dart';

import 'package:fuzzysnap/pages/home_page.dart';
import 'package:fuzzysnap/pages/main_page.dart';
import 'package:fuzzysnap/pages/notification_page.dart';
import 'package:fuzzysnap/pages/splash/splash_page.dart';
import 'package:fuzzysnap/provider/friend_requests_provider.dart';
import 'package:fuzzysnap/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final cameras = await availableCameras();

  tz.initializeTimeZones(); // Khởi tạo múi giờ

  // Khởi tạo và yêu cầu quyền cho thông báo
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ],
    child: MyApp(cameras: cameras),
  ));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UiProvider()..init(),
      child:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,

          //Our custom theme applied
          darkTheme: notifier.isDark ? notifier.darkTheme : notifier.lightTheme,

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              surface: Colors.white,
              primary: Colors.black,
              secondary: Colors.black,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: Color(0xFF6D9886) // Màu cho CircularProgressIndicator
                ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/auth_page': (context) => AuthPage(cameras: cameras),
            '/login_register_page': (context) => const LoginOrRegisterPage(),
            '/main_page': (context) => MainPage(
                  cameras: cameras,
                ),
            '/home_page': (context) => HomePage(),
            '/notification_page': (context) => const NotificationPage(),
            '/camera_page': (context) => CameraPage(
                  cameras: cameras,
                ),
            '/chat_page': (context) => const ChatListPage(),
          },
        );
      }),
    );
  }
}
