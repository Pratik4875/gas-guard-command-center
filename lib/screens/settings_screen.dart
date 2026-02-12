import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/config_service.dart';
import 'dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class SettingsScreen extends StatefulWidget {
  final bool isFirstRun;

  const SettingsScreen({super.key, this.isFirstRun = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _appIdController = TextEditingController();
  final _messagingSenderIdController = TextEditingController(); 

  String? _parseMessage;
  bool _isLoading = false;

  void _parseConfigInput(String input) {
    if (input.isEmpty) return;

    // regex helpers
    String? extract(String key) {
      final regex = RegExp('$key: ["\'](.*?)["\']');
      final match = regex.firstMatch(input);
      return match?.group(1);
    }

    final dbUrl = extract('databaseURL');
    final apiKey = extract('apiKey');
    final projectId = extract('projectId');
    final appId = extract('appId');
    final msgId = extract('messagingSenderId');

    if (dbUrl != null || apiKey != null) {
      setState(() {
        if (dbUrl != null) _dbUrlController.text = dbUrl;
        if (apiKey != null) _apiKeyController.text = apiKey;
        if (projectId != null) _projectIdController.text = projectId;
        if (appId != null) _appIdController.text = appId;
        if (msgId != null) _messagingSenderIdController.text = msgId;
        _parseMessage = "✅ Auto-detected configuration!";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final settings = await ConfigService().getSettings();
    setState(() {
      _dbUrlController.text = settings['dbUrl'] ?? '';
      _apiKeyController.text = settings['apiKey'] ?? '';
      _projectIdController.text = settings['projectId'] ?? '';
      _appIdController.text = settings['appId'] ?? '';
      _messagingSenderIdController.text = settings['messagingSenderId'] ?? '';
    });
  }

  Future<void> _saveAndConnect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Save to Storage
      await ConfigService().saveSettings(
        dbUrl: _dbUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        projectId: _projectIdController.text.trim(),
        appId: _appIdController.text.trim(),
        messagingSenderId: _messagingSenderIdController.text.trim(),
      );

      // 2. Try to Initialize Firebase with these new settings
      // We might need to re-initialize if it was already initialized.
      // For simplicity, we might ask the user to restart, or try to init here.
      try {
        if (Firebase.apps.isNotEmpty) {
          await Firebase.app().delete(); // Reset existing app
        }
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: _apiKeyController.text.trim(),
            appId: _appIdController.text.trim(),
            messagingSenderId: _messagingSenderIdController.text.trim(),
            projectId: _projectIdController.text.trim(),
            databaseURL: _dbUrlController.text.trim(),
          ),
        );
      } catch (e) {
        // If init fails, valid creds might be wrong
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Error connecting to Firebase: $e")),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (widget.isFirstRun) {
        // Navigate to Dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pop(); // Go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Settings Saved! Reconnecting...")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving settings: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          "SYSTEM CONFIGURATION",
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Connect to your Firebase Project",
                    style: GoogleFonts.orbitron(fontSize: 18, color: const Color(0xFF00E5FF)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter the details from your google-services.json or Firebase Console.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // --- Smart Import Section ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1E33),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "🚀 EASY SETUP",
                          style: GoogleFonts.orbitron(
                              color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Copy the 'firebaseConfig' code block from Firebase Console and paste it here:",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Paste code here (const firebaseConfig = { ... })',
                            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.3)),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.all(10),
                          ),
                          onChanged: _parseConfigInput,
                        ),
                        if (_parseMessage != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            _parseMessage!,
                            style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                          )
                        ]
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // --- Advanced Fields (Auto-filled) ---
                  ExpansionTile(
                    title: Text("Advanced Details (Auto-filled)", style: GoogleFonts.roboto(color: Colors.white70)),
                    children: [
                       _buildTextField(
                        controller: _dbUrlController,
                        label: "Database URL",
                        hint: "https://your-project.firebaseio.com",
                        icon: Icons.link,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _apiKeyController,
                        label: "API Key",
                        hint: "AIzaSy...",
                        icon: Icons.vpn_key,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _projectIdController,
                        label: "Project ID",
                        hint: "gas-leak-project",
                        icon: Icons.work,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _appIdController,
                        label: "App ID",
                        hint: "1:123456789:android:...",
                        icon: Icons.apps,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _messagingSenderIdController,
                        label: "Messaging Sender ID",
                        hint: "123456789",
                        icon: Icons.message,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
                      : ElevatedButton.icon(
                          onPressed: _saveAndConnect,
                          icon: const Icon(Icons.rocket_launch),
                          label: Text(widget.isFirstRun ? "LAUNCH MISSION CONTROL" : "SAVE CONFIGURATION"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            foregroundColor: const Color(0xFF00E5FF),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                            side: const BorderSide(color: Color(0xFF00E5FF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00E5FF)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
