
abstract class NotificationService {
  Future<void> init();
  Future<void> showNotification(String title, String body);
} 
