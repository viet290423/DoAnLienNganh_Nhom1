import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Cấu hình FCM và thông báo cục bộ
  Future<void> initNotifications() async {
    // Yêu cầu quyền nhận thông báo
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Người dùng đã cho phép nhận thông báo.');
    } else {
      print('Người dùng không cho phép nhận thông báo.');
      return;
    }

    // Đăng ký xử lý khi nhận thông báo
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Tin nhắn mới: ${message.notification?.title}');
      _showNotification(
        title: message.notification?.title ?? 'Tin nhắn mới',
        body: message.notification?.body ?? '',
        payload: message.data,
      );
    });

    // Xử lý khi người dùng nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      
    });

    // Lấy token FCM
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
    // Gửi token này đến server để gửi thông báo
  }

  /// Hiển thị thông báo cục bộ
  Future<void> _showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_notifications', // ID kênh thông báo
      'Chat Notifications', // Tên kênh
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      0, // ID thông báo
      title,
      body,
      notificationDetails,
      payload: payload['username'], // Chứa dữ liệu tùy chọn nếu cần
    );
  }

  /// Khởi tạo plugin thông báo cục bộ
  Future<void> configureLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await _localNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        print('Thông báo được chọn với dữ liệu: ${response.payload}');
        // Thêm logic điều hướng tại đây nếu cần
      }
    },
  );
}

}
