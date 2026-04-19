// lib/config/api_config.dart
import 'backend_config.dart';

class ApiConfig {
  // Backend is always available (it handles API keys securely)
  static bool get hasGeminiKey => true;
  static bool get hasGroqKey => true;
  
  // These now point to our backend
  static String get geminiBaseUrl => BackendConfig.geminiEndpoint;
  static String get groqBaseUrl => BackendConfig.groqEndpoint;
  
  static const String groqModel = 'llama-3.1-8b-instant';
}
