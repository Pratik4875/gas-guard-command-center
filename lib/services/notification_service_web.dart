
import 'package:universal_html/html.dart' as html;
import 'notification_service_interface.dart';

class NotificationServiceImplementation implements NotificationService {
  @override
  Future<void> init() async {
    // Request permission on Web
    html.Notification.requestPermission();
  }

  @override
  Future<void> showNotification(String title, String body) async {
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body, icon: '/icons/Icon-192.png');
    }
  }
}
