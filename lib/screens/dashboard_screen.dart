import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Import timer
import 'dart:math'; // For random

import 'analytics_screen.dart';
import 'settings_screen.dart';

import 'package:firebase_database/firebase_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Data variables
  double gasLevel = 0.0;
  List<double> weeklyAqi = [45, 50, 48, 52, 60, 55, 58]; // Mock data for now
  StreamSubscription<DatabaseEvent>? _gasStream;
  bool _alertShown = false; 

  @override
  void initState() {
    super.initState();
    _activateListeners();
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

  void _checkAlert() {
    // Show alert if high and not already shown recently
    if (gasLevel > 300 && !_alertShown) {
      _showNotificationLikePopup();
      _alertShown = true;
      // Reset alert flag after 10 seconds so it can show again
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) setState(() => _alertShown = false);
      });
    }
  }

  void _showNotificationLikePopup() {
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
          "High levels of gas detected (${gasLevel.toInt()} PPM). Evaluate the area immediately!",
          style: GoogleFonts.roboto(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("DISMISS", style: TextStyle(color: Theme.of(context).primaryColor)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gasStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine status based on gas level
    String statusText = "AIR QUALITY: SAFE";
    Color statusColor = const Color(0xFF00E5FF); // Cyan
    Color bgColor = Colors.transparent;
    
    if (gasLevel > 300) {
      statusText = "⚠ WARNING: GAS DETECTED!";
      statusColor = const Color(0xFFFF2E63); // Neon Red
      bgColor = statusColor.withOpacity(0.1); // Red tint background
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          "MISSION CONTROL",
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
           IconButton(
             icon: const Icon(Icons.analytics_outlined),
             onPressed: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => AnalyticsScreen(weeklyAqi: weeklyAqi)),
               );
             },
           ),
           IconButton(
             icon: const Icon(Icons.settings),
             onPressed: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => const SettingsScreen()), // Opens settings
               );
             },
           )
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Status Indicator (Big gauge)
              CircularPercentIndicator(
                radius: 150.0,
                lineWidth: 30.0,
                percent: (gasLevel / 1000).clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gasLevel.toInt().toString(),
                      style: GoogleFonts.orbitron(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "PPM",
                      style: GoogleFonts.orbitron(fontSize: 24, color: Colors.grey),
                    ),
                  ],
                ),
                progressColor: statusColor,
                backgroundColor: Colors.white10,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animateFromLastPercent: true,
              ),
              
              const SizedBox(height: 50),
              
              // 2. Status Message
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
                       gasLevel > 300 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
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
              
              // 3. Navigation Button
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
          ),
        ),
      ),
    );
  }
}

