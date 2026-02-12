import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class GasDataService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Stream of gas levels (0-1024)
  Stream<int> get gasLevelStream {
    return _db.child('sensor/gas_level').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is int) {
        return value;
      } else if (value is double) {
        return value.toInt();
      }
      return 0; // Default or error
    });
  }

  // Stream of weekly AQI history (List of doubles)
  Stream<List<double>> get weeklyHistoryStream {
    return _db.child('sensor/history').onValue.map((event) {
      // Expecting a list or map of values in Firebase
      // For simplicity, we just return a fixed list if null, or parse
      // This is where we'd parse the actual weekly data
      return [45.0, 50.0, 48.0, 55.0, 60.0, 58.0, 52.0];
    });
  }
}
