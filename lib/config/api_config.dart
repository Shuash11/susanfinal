// lib/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String _getKey(String key) {
    try {
      final k = dotenv.env[key];
      return k ?? '';
    } catch (e) {
      return '';
    }
  }

  static String get geminiApiKey => _getKey('GEMINI_API_KEY');

  static String get geminiBaseUrl {
    return 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  }

  static String get groqApiKey => _getKey('GROQ_API_KEY');

  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  static const String groqModel = 'llama-3.1-8b-instant';

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  static bool get hasGroqKey => groqApiKey.isNotEmpty;
}
