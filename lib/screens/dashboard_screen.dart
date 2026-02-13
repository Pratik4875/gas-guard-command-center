import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Import timer
import 'dart:math'; // For random

import 'analytics_screen.dart';
import 'settings_screen.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:gas_leak_detection/services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  final bool isConfigured;
  const DashboardScreen({super.key, this.isConfigured = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Data variables
  double gasLevel = 0.0;
  List<double> weeklyAqi = [45, 50, 48, 52, 60, 55, 58]; // Mock data for now
  StreamSubscription<DatabaseEvent>? _gasStream;
  Timer? _demoTimer;
  // Alert management
  bool _isDialogVisible = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    if (widget.isConfigured) {
      _activateListeners();
    } else {
      _startDemoMode();
    }
    _notificationService.init();
  }

  void _activateListeners() {
    // Listen to 'sensor/gas_level' path
    _gasStream = FirebaseDatabase.instance
        .ref('sensor/gas_level')
        .onValue
        .listen((event) {
      final value = event.snapshot.value;
      if (value != null && mounted) {
        setState(() {
          // Convert to double safely
          gasLevel = double.tryParse(value.toString()) ?? 0.0;
        });
        _checkAlert();
      }
    });
  }

  void _startDemoMode() {
    // Simulate gas level changes for demo purposes
    _demoTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          // Sine wave simulation for smooth fluctuation + random noise
          double time = DateTime.now().millisecondsSinceEpoch / 1000.0;
          double base = 150 + (50 * sin(time)); // Oscillates between 100 and 200
          double noise = Random().nextDouble() * 20;
          gasLevel = base + noise;

          // Occasionally spike to trigger alert visualization (every ~30 seconds)
          if (time % 30 < 2) {
            gasLevel = 350 + Random().nextDouble() * 50;
          }
        });
        _checkAlert();
      }
    });
  }

  void _checkAlert() {
    // 1. If gas is HIGH (>600)
    if (gasLevel > 600) {
      // Show Notification (System) - throttling to avoid spamming every second
      // We rely on the periodic check or existing state to not spam too hard, 
      // but for now let's just show it if we haven't shown the dialog recently.
      if (!_isDialogVisible) {
        _showNotificationLikePopup();
        _notificationService.showNotification(
          '⚠️ GAS LEAK DETECTED!', 
          'Level: ${gasLevel.toInt()} PPM. Evacuate safely.'
        );
      }
    } 
    // 2. If gas is LOW (<600) but dialog is still open -> Dismiss it
    else if (gasLevel <= 600 && _isDialogVisible) {
      Navigator.of(context).pop(); // Close the dialog
      _isDialogVisible = false;
    }
  }

  void _showNotificationLikePopup() {
    _isDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33).withOpacity(0.95),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFF2E63), width: 2)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF2E63), size: 30),
            const SizedBox(width: 10),
            Text("GAS LEAK DETECTED!",
                style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          widget.isConfigured 
            ? "High levels of gas detected (${gasLevel.toInt()} PPM). Evaluate the area immediately!"
            : "DEMO ALERT: High gas level simulation (${gasLevel.toInt()} PPM).",
          style: GoogleFonts.roboto(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.of(ctx).pop();
               _isDialogVisible = false;
            },
            child: Text("DISMISS", style: TextStyle(color: Theme.of(context).primaryColor)),
          )
        ],
      ),
    ).then((_) {
      // Ensure flag is reset if dialog is closed by other means (e.g. back button)
      if (mounted) {
        _isDialogVisible = false;
      }
    });
  }

  @override
  void dispose() {
    _gasStream?.cancel();
    _demoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine status based on gas level
    String statusText = "AIR QUALITY: SAFE";
    Color statusColor = const Color(0xFF00E5FF); // Cyan
    Color bgColor = Colors.transparent;
    
    if (gasLevel > 600) { // Changed from 300 to 600
      statusText = "⚠ WARNING: GAS DETECTED!";
      statusColor = const Color(0xFFFF2E63); // Neon Red
      bgColor = statusColor.withOpacity(0.1); // Red tint background
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Row(
          children: [
            Text("Dashboard", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(width: 8),
              // v2.0 Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF08D9D6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF08D9D6), width: 1),
                ),
                child: Text("v2.0", style: GoogleFonts.roboto(fontSize: 10, color: const Color(0xFF08D9D6), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png', errorBuilder: (c,o,s) => const Icon(Icons.shield, color: Color(0xFF00E5FF))),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
           IconButton(
             padding: EdgeInsets.zero,
             icon: const Icon(Icons.analytics_outlined),
             onPressed: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => AnalyticsScreen(weeklyAqi: weeklyAqi)),
               );
             },
           ),
           Container(
             margin: const EdgeInsets.only(right: 10),
             child: IconButton(
               icon: Icon(
                 widget.isConfigured ? Icons.settings : Icons.perm_identity, 
                 color: widget.isConfigured ? Colors.white : const Color(0xFF00E5FF)
               ),
               tooltip: widget.isConfigured ? "Settings" : "Connect Setup",
               onPressed: () {
                 Navigator.push(
                   context, 
                   MaterialPageRoute(builder: (context) => const SettingsScreen()), 
                 );
               },
             ),
           )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;

              // Common Widgets
              Widget gauge = CircularPercentIndicator(
                radius: isWide ? 180.0 : 150.0,
                lineWidth: isWide ? 40.0 : 30.0,
                percent: (gasLevel / 1000).clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gasLevel.toInt().toString(),
                      style: GoogleFonts.orbitron(
                        fontSize: isWide ? 90 : 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "PPM",
                      style: GoogleFonts.orbitron(fontSize: isWide ? 30 : 24, color: Colors.grey),
                    ),
                  ],
                ),
                progressColor: statusColor,
                backgroundColor: Colors.white10,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animateFromLastPercent: true,
                animationDuration: 1000, 
              );

              Widget statusInfo = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                           gasLevel > 600 ? Icons.warning_amber_rounded : Icons.check_circle_outline, // Changed from 300 to 600
                           color: statusColor,
                           size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          statusText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => AnalyticsScreen(weeklyAqi: weeklyAqi)),
                      );
                    },
                    icon: const Icon(Icons.show_chart),
                    label: const Text("VIEW WEEKLY REPORT"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF00E5FF)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      textStyle: GoogleFonts.orbitron(),
                    ),
                  )
                ],
              );

              return AnimatedContainer(
                duration: const Duration(seconds: 1),
                padding: const EdgeInsets.only(bottom: 80), // Prevent overlap with banner
                decoration: BoxDecoration(
                  color: bgColor,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      const Color(0xFF1D1E33),
                      const Color(0xFF0A0E21),
                    ],
                  ),
                ),
                child: isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: Center(child: gauge)),
                          Expanded(child: Center(child: statusInfo)),
                        ],
                      )
                    : Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              gauge,
                              const SizedBox(height: 50),
                              statusInfo,
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
              );
            },
          ),
          
          // Connection Warning Banner (if not configured)
          if (!widget.isConfigured)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.amber.withOpacity(0.9),
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    return isMobile 
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.link_off, color: Colors.black),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    "DEMO MODE ACTIVE",
                                    style: GoogleFonts.orbitron(
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                                "No Database Connected",
                                style: GoogleFonts.roboto(
                                  color: Colors.black87,
                                  fontSize: 12
                                ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                   Navigator.push(
                                     context, 
                                     MaterialPageRoute(builder: (context) => const SettingsScreen()), 
                                   );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text("CONNECT NOW"),
                              ),
                            )
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.link_off, color: Colors.black),
                            const SizedBox(width: 10),
                            Text(
                              "NO DATABASE CONNECTED • DEMO MODE ACTIVE",
                              style: GoogleFonts.orbitron(
                                color: Colors.black, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                 Navigator.push(
                                   context, 
                                   MaterialPageRoute(builder: (context) => const SettingsScreen()), 
                                 );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text("CONNECT NOW"),
                            )
                          ],
                        );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

