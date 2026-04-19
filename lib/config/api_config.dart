// lib/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get geminiApiKey {
    try {
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key == null || key.isEmpty) {
        return '';
      }
      return key;
    } catch (e) {
      return '';
    }
  }

  static String get geminiBaseUrl {
    return 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  }

  static String get groqApiKey {
    try {
      final key = dotenv.env['GROQ_API_KEY'];
      if (key == null || key.isEmpty) {
        return '';
      }
      return key;
    } catch (e) {
      return '';
    }
  }

  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  static const String groqModel = 'llama-3.1-8b-instant';

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  static bool get hasGroqKey => groqApiKey.isNotEmpty;
}
