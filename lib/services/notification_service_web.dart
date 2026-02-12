
import 'package:universal_html/html.dart' as html;
import 'notification_service_interface.dart';

class NotificationServiceImplementation implements NotificationService {
  @override
  Future<void> init() async {
    try {
      // Check if Notifications are supported before requesting
      if (html.Notification.supported) {
        html.Notification.requestPermission();
      } else {
        print("Notifications not supported on this browser.");
      }
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  @override
  Future<void> showNotification(String title, String body) async {
    try {
      if (html.Notification.supported && html.Notification.permission == 'granted') {
        html.Notification(title, body: body, icon: '/icons/Icon-192.png');
      }
    } catch (e) {
      print("Error showing notification: $e");
    }
  }
}
