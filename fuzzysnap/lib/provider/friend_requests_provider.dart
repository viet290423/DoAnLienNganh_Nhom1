import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fuzzysnap/pages/main_page.dart';

class NotificationProvider extends ChangeNotifier {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Set<String> _notifiedRequests = {}; // Theo dõi lời mời đã thông báo

  NotificationProvider() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iOSInitSettings =
      DarwinInitializationSettings();
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings, iOS: iOSInitSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload == 'friend_request') {
        // Chuyển sang tab Notification
        MainPage.mainPageKey.currentState?.navigateToTab(1);
      }
    },
  );
}


  Future<void> showFriendRequestNotification(String username) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'friend_request_channel_id',
      'Friend Request Notifications',
      channelDescription: 'Notifications for new friend requests',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Friend Request',
      '$username has sent you a friend request.',
      notificationDetails,
      payload: 'friend_request', // Optional payload
    );
  }

  void listenToFriendRequests(String userId) {
    FirebaseFirestore.instance
        .collection('FriendRequests')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        List<dynamic> requests = snapshot.data()?['requests'] ?? [];

        if (requests.isNotEmpty) {
          // Lấy yêu cầu mới nhất
          Map<String, dynamic> latestRequest = requests.last;

          // Hiển thị thông báo
          showFriendRequestNotification(latestRequest['username']);
        }
      }
    });
  }}
