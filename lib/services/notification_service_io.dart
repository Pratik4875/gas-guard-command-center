
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service_interface.dart';
import 'dart:io';

class NotificationServiceImplementation implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    // Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    // Linux
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    // Windows
    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'Gas Guard',
      appUserModelId: 'com.example.gas_leak_detection.GasGuard',
      guid: '7b6d80z2-8z1q-4e12-8f12-9c1c4e9d1234', // Random GUID
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings, // Named parameter 'settings'
    );

    // Platform-specific runtime permissions
    if (Platform.isAndroid) {
         await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  @override
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'gas_alert_channel', 'Gas Alerts',
            channelDescription: 'High priority alerts for gas leaks',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true);

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
