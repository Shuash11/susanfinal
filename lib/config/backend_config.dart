// lib/config/backend_config.dart
import 'package:flutter/foundation.dart' show kIsWeb;

class BackendConfig {
  static String _getBackendUrl() {
    if (kIsWeb) {
      final url = String.fromEnvironment('BACKEND_URL', defaultValue: '');
      if (url.isNotEmpty) return url;
    }
    return 'https://susanfinal.onrender.com';
  }

  static final String _baseUrl = _getBackendUrl();
  
  static String get geminiEndpoint => '$_baseUrl/chat/gemini';
  static String get groqEndpoint => '$_baseUrl/chat/groq';
  static String get healthEndpoint => '$_baseUrl/health';
}