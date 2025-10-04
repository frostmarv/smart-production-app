// lib/services/environment_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentService {
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  static String get apiUrl {
    final url = dotenv.env['API_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_URL tidak ditemukan di .env');
    }
    return url;
  }
}