import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/account/account_page.dart';
import 'package:fuzzysnap/pages/add_post/camera_page.dart';
import 'package:fuzzysnap/pages/chat/chat_list.dart';
import 'package:fuzzysnap/pages/home_page.dart';
import 'package:fuzzysnap/pages/notification_page.dart';
import 'package:fuzzysnap/provider/friend_requests_provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';

class MainPage extends StatefulWidget {
  static final GlobalKey<_MainPageState> mainPageKey = GlobalKey(); // Key để truy cập state

  final List<CameraDescription> cameras;
  final String? selectedPostId; // Nhận tham số selectedPostId

  const MainPage({super.key, required this.cameras, this.selectedPostId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Tab hiện tại
  final NotificationProvider notificationProvider = NotificationProvider();

  @override
  void initState() {
    super.initState();

    // Nếu có selectedPostId, đảm bảo chuyển đến HomePage (tab index = 0)
    if (widget.selectedPostId != null) {
      _currentIndex = 0;
    }

    // Lắng nghe thông báo yêu cầu kết bạn
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      notificationProvider.listenToFriendRequests(currentUser.uid);
    }
  }

  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index; // Chuyển tab bằng cách thay đổi _currentIndex
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildPage(_currentIndex), // Hiển thị page theo tab hiện tại
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
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
        // Truyền selectedPostId vào HomePage nếu có
        return HomePage(selectedPostId: widget.selectedPostId);
      case 1:
        return const NotificationPage();
      case 2:
        return CameraPage(cameras: widget.cameras);
      case 3:
        return const ChatListPage();
      case 4:
        return AccountPage(cameras: widget.cameras,);
      default:
        return const HomePage();
    }
  }
}
