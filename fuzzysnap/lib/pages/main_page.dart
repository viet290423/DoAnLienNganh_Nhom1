import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/account/account_page.dart';
import 'package:fuzzysnap/pages/account/profile_page.dart';
import 'package:fuzzysnap/pages/add_post/camera_page.dart';
import 'package:fuzzysnap/pages/chat/chat_page.dart';
import 'package:fuzzysnap/pages/home_page.dart';
import 'package:fuzzysnap/pages/notification_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Sử dụng widget.cameras để truyền danh sách camera
  final List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách các màn hình, bao gồm HomePage và CameraPage
    screens.addAll([
      HomePage(),
      NotificationPage(),
      CameraPage(cameras: widget.cameras), // Truyền cameras cho CameraPage
      ChatPage(),
      AccountPage()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.onPrimary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            selectedIndex: _currentIndex,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            color: Colors.grey[400],
            activeColor: Theme.of(context).colorScheme.onSecondary,
            tabBackgroundColor: Theme.of(context).colorScheme.onPrimary,
            gap: 5,
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: CupertinoIcons.bell,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: CupertinoIcons.camera,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: CupertinoIcons.conversation_bubble,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: CupertinoIcons.person,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ],
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
