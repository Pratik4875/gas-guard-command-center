
import 'notification_service_interface.dart';
export 'notification_service_interface.dart';

// Conditionally import the implementation
import 'notification_service_io.dart' if (dart.library.html) 'notification_service_web.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late final NotificationServiceImplementation _impl;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _impl = NotificationServiceImplementation();
  }

  Future<void> init() => _impl.init();

  Future<void> showNotification(String title, String body) => 
      _impl.showNotification(title, body);
}
