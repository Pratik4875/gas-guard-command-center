import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'services/config_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if we have saved settings
  final configService = ConfigService();
  final hasSettings = await configService.hasSettings();
  bool isConfigured = false;

  if (hasSettings) {
    try {
      final settings = await configService.getSettings();
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: settings['apiKey']!,
          appId: settings['appId']!,
          messagingSenderId: settings['messagingSenderId']!,
          projectId: settings['projectId']!,
          databaseURL: settings['dbUrl']!,
        ),
      );
      isConfigured = true;
    } catch (e) {
      print("Error initializing Firebase from saved settings: $e");
      isConfigured = false;
    }
  }

  runApp(GasLeakDetectorApp(isConfigured: isConfigured));
}

class GasLeakDetectorApp extends StatelessWidget {
  final bool isConfigured;

  const GasLeakDetectorApp({super.key, required this.isConfigured});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gas Guard Command Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21), // Deep space blue/black
        primaryColor: const Color(0xFF00E5FF), // Cyan neon
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF2E63), // Neon Red
          surface: Color(0xFF111328),
          background: Color(0xFF0A0E21),
        ),
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: const Color(0xFF00E5FF),
          ),
        ),
      ),
      home: DashboardScreen(isConfigured: isConfigured),
    );
  }
}
