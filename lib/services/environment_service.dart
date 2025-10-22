// lib/services/environment_service.dart
class EnvironmentService {
  static const String _defaultApiUrl = 'http://103.235.75.49';
  
  static Future<void> init() async {
    // No longer loading .env file
    // Environment variables should be set via Codemagic or build configuration
  }

  static String get apiUrl {
    // Use environment variable from build or default
    const apiUrl = String.fromEnvironment('API_BASE_URL', defaultValue: _defaultApiUrl);
    return apiUrl;
  }
  
  static String get apiBaseUrl => apiUrl;
}