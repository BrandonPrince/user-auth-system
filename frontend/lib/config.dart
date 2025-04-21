import 'package:flutter/foundation.dart';

class Config {
  static String get backendUrl {
    // For Android emulator, use 10.0.2.2
    // For web or other platforms, use localhost
    return kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
    // Note: For web, if localhost times out, update to host IP (e.g., http://192.168.x.x:8000)
  }
}