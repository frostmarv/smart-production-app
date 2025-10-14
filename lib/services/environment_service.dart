// lib/services/environment_service.dart
class EnvironmentService {
  static const String _defaultApiUrl = 'https://74138657-bc62-468d-88d5-c86cb249f99b-00-ccopf7crimmu.worf.replit.dev';
  
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