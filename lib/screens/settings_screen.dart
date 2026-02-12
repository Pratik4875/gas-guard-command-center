import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/config_service.dart';
import 'dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Temporarily init Firebase to test connection
      try {
        if (Firebase.apps.isNotEmpty) {
          await Firebase.app().delete();
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

        // 2. Test Connection explicitly
        // We try to access the root reference to ensure the URL is valid and reachable.
        // Reading '.info/connected' is a standard way to check state, but a simple root check works too.
        await FirebaseDatabase.instance.ref().root.get().timeout(const Duration(seconds: 5));
        
      } catch (e) {
        throw "Connection failed. Please check your URL and keys. ($e)";
      }

      // 3. Save to Storage only if connection succeeded
      await ConfigService().saveSettings(
        dbUrl: _dbUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        projectId: _projectIdController.text.trim(),
        appId: _appIdController.text.trim(),
        messagingSenderId: _messagingSenderIdController.text.trim(),
      );

      if (widget.isFirstRun) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Settings Saved & Connected! 🚀")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isFirstRun 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF)),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            radius: 1.5,
            colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 900;

            if (isWide) {
              return Row(
                children: [
                  // Left Side: Branding / Hero
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 100, color: const Color(0xFF00E5FF).withOpacity(0.8)),
                          const SizedBox(height: 30),
                          Text(
                            "GAS GUARD",
                            style: GoogleFonts.orbitron(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 5,
                            ),
                          ),
                          Text(
                            "COMMAND CENTER",
                            style: GoogleFonts.orbitron(
                              fontSize: 30,
                              color: const Color(0xFF00E5FF),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Secure. Monitor. Protect.\nInitialize your system parameters to begin.",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: Colors.white60,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right Side: Form
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _buildFormCard(),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Mobile / Narrow Layout
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 60, color: const Color(0xFF00E5FF).withOpacity(0.8)),
                      const SizedBox(height: 20),
                      Text(
                        "GAS GUARD",
                        style: GoogleFonts.orbitron(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildFormCard(),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      color: const Color(0xFF1D1E33).withOpacity(0.9), // Glassy dark
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.1)),
      ),
      elevation: 20,
      shadowColor: const Color(0xFF00E5FF).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "SYSTEM CONFIGURATION",
                style: GoogleFonts.orbitron(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // --- Smart Import Section ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch, color: Color(0xFF00E5FF), size: 18),
                        const SizedBox(width: 10),
                        Text(
                          "QUICK SETUP",
                          style: GoogleFonts.orbitron(
                              color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Paste 'firebaseConfig' from Console",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: '{ apiKey: "...", ... }',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.transparent,
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
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  collapsedIconColor: Colors.white54,
                  iconColor: const Color(0xFF00E5FF),
                  title: Text("Advanced Settings",
                      style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14)),
                  children: [
                    _buildTextField(
                      controller: _dbUrlController,
                      label: "Database URL",
                      hint: "https://...",
                      icon: Icons.link,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _apiKeyController,
                      label: "API Key",
                      hint: "AIzaSy...",
                      icon: Icons.vpn_key,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _projectIdController,
                      label: "Project ID",
                      hint: "gas-leak-project",
                      icon: Icons.work,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _appIdController,
                      label: "App ID",
                      hint: "1:123...",
                      icon: Icons.apps,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _messagingSenderIdController,
                      label: "Sender ID",
                      hint: "123...",
                      icon: Icons.message,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
                  : MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ElevatedButton(
                        onPressed: _saveAndConnect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 10,
                          shadowColor: const Color(0xFF00E5FF).withOpacity(0.4),
                        ),
                        child: Text(widget.isFirstRun
                            ? "INITIALIZE SYSTEM"
                            : "SAVE CONFIGURATION"),
                      ),
                    ),
            ],
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
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
