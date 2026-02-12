import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _keyDbUrl = 'firebase_db_url';
  static const String _keyApiKey = 'firebase_api_key';
  static const String _keyProjectId = 'firebase_project_id';
  static const String _keyAppId = 'firebase_app_id';
  static const String _keyMessagingSenderId = 'firebase_messaging_sender_id';

  Future<void> saveSettings({
    required String dbUrl,
    required String apiKey,
    required String projectId,
    required String appId,
    required String messagingSenderId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDbUrl, dbUrl);
    await prefs.setString(_keyApiKey, apiKey);
    await prefs.setString(_keyProjectId, projectId);
    await prefs.setString(_keyAppId, appId);
    await prefs.setString(_keyMessagingSenderId, messagingSenderId);
  }

  Future<Map<String, String?>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'dbUrl': prefs.getString(_keyDbUrl),
      'apiKey': prefs.getString(_keyApiKey),
      'projectId': prefs.getString(_keyProjectId),
      'appId': prefs.getString(_keyAppId),
      'messagingSenderId': prefs.getString(_keyMessagingSenderId),
    };
  }

  Future<bool> hasSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyDbUrl) && prefs.containsKey(_keyApiKey);
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
