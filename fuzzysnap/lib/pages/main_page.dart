import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/account/account_page.dart';
import 'package:fuzzysnap/pages/add_post/camera_page.dart';
import 'package:fuzzysnap/pages/chat/chat_list.dart';
import 'package:fuzzysnap/pages/chat/chat_page.dart';
import 'package:fuzzysnap/pages/home_page.dart';
import 'package:fuzzysnap/pages/notification_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainPage({super.key, required this.cameras});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildPage(_currentIndex), // Load lại page mỗi khi đổi tab
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.2), // Màu và độ trong suốt của shadow
              spreadRadius: 2, // Bán kính mở rộng
              blurRadius: 10, // Độ mờ của shadow
              offset:
                  const Offset(0, -2), // Hướng của shadow (ở trên - y là số âm)
            ),
          ],
        ),
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
                icon: Iconsax.home,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: Iconsax.notification,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: Iconsax.camera,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: Iconsax.messages,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              GButton(
                icon: Iconsax.user,
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

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return const NotificationPage();
      case 2:
        return CameraPage(
            cameras: widget.cameras); // Truyền cameras cho CameraPage
      case 3:
        return const ChatListPage();
      case 4:
        return const AccountPage();
      default:
        return HomePage();
    }
  }
}
