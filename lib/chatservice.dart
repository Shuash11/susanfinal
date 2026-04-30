// lib/chatservice.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';
import 'message_model.dart';

enum ChatProvider { studyBuddyThinker, studyBuddyFast, studyBuddyJuniorCoder, studyBuddyGeneralTask }

class ChatService {
  final Map<String, List<Map<String, dynamic>>> _histories = {};
  final Map<String, List<Map<String, dynamic>>> _groqHistories = {};
  final http.Client _client = http.Client();

  bool _isCancelled = false;

  void cancelCurrentRequest() {
    _isCancelled = true;
  }

  void dispose() {
    _client.close();
  }

  Stream<String> sendMessageStream(
    String userMessage, {
    required String sessionId,
    required List<MessageModel> sessionMessages,
    ChatProvider? preferredProvider,
  }) async* {
    _isCancelled = false;

    ChatProvider firstProvider = preferredProvider ?? ChatProvider.studyBuddyFast;
    ChatProvider fallbackProvider = _getFallbackProvider(firstProvider);

    String? lastError;

    for (final provider in [firstProvider, fallbackProvider]) {
      if (_isCancelled) break;

      try {
        if (provider == ChatProvider.studyBuddyThinker && ApiConfig.hasGeminiKey) {
          yield* _sendGeminiStream(userMessage, sessionId, sessionMessages);
          return;
        } else if (provider == ChatProvider.studyBuddyFast && ApiConfig.hasGroqKey) {
          yield* _sendGroqStream(userMessage, sessionId, sessionMessages);
          return;
        } else if (provider == ChatProvider.studyBuddyJuniorCoder && ApiConfig.hasGroqKey) {
          yield* _sendGroqStream(userMessage, sessionId, sessionMessages);
          return;
        } else if (provider == ChatProvider.studyBuddyGeneralTask && ApiConfig.hasGroqKey) {
          yield* _sendGroqStream(userMessage, sessionId, sessionMessages);
          return;
        }
      } catch (e) {
        lastError = '${provider.name} failed: ${e.toString()}';

        if (_isCancelled) break;

        final errStr = e.toString();
        if (errStr.contains('429') || errStr.contains('quota') ||
            errStr.contains('RESOURCE_EXHAUSTED') || errStr.contains('rate limit')) {
          continue;
        }
      }
    }

    throw Exception(lastError ?? 'Both AI services failed. Please try again later.');
  }

  ChatProvider _getFallbackProvider(ChatProvider provider) {
    if (provider == ChatProvider.studyBuddyThinker) return ChatProvider.studyBuddyFast;
    if (provider == ChatProvider.studyBuddyFast) return ChatProvider.studyBuddyJuniorCoder;
    if (provider == ChatProvider.studyBuddyJuniorCoder) return ChatProvider.studyBuddyGeneralTask;
    if (provider == ChatProvider.studyBuddyGeneralTask) return ChatProvider.studyBuddyThinker;
    return ChatProvider.studyBuddyThinker;
  }

  Stream<String> _sendGeminiStream(String userMessage, String sessionId, List<MessageModel> sessionMessages) async* {
    final history = _histories.putIfAbsent(sessionId, () => []);

    for (final msg in sessionMessages) {
      if (msg.content.isNotEmpty) {
        final role = msg.role == MessageRole.user ? 'user' : 'model';
        final parts = msg.role == MessageRole.user
            ? [{'text': msg.content}]
            : [{'text': msg.content}];
        if (history.isEmpty || history.last['role'] != role) {
          history.add({'role': role, 'parts': parts});
        }
      }
    }

    history.add({'role': 'user', 'parts': [{'text': userMessage}]});

    final apiKey = ApiConfig.geminiApiKey;
    final baseUrl = ApiConfig.geminiBaseUrl;

    if (apiKey.isEmpty) {
      throw Exception('Gemini API key is empty. Check .env or build config.');
    }

    final url = Uri.parse(
      '${baseUrl.replaceAll('generateContent', 'streamGenerateContent')}?key=$apiKey',
    );

    // Use shared client for connection pooling
    // final client = http.Client(); - now uses instance
    final StringBuffer fullReply = StringBuffer();

    try {
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({
          'contents': history,
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1024},
        });

      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 30));

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        history.removeLast();
        throw Exception('Gemini API error ${streamedResponse.statusCode}: $errorBody');
      }

      String leftover = '';
      await for (final raw in streamedResponse.stream.transform(utf8.decoder)) {
        if (_isCancelled) break;

        final combined = leftover + raw;
        leftover = '';
        final lines = combined.split('\n');

        for (int i = 0; i < lines.length; i++) {
          if (_isCancelled) break;

          final line = lines[i].trim();
          if (i == lines.length - 1 && !combined.endsWith('\n')) {
            leftover = lines[i];
            continue;
          }
          if (!line.startsWith('data: ')) continue;
          final jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty) continue;

          try {
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final candidate = data['candidates']?[0];
            final content = candidate?['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.isNotEmpty) {
                fullReply.write(text);
                yield text;
              }
            }
          } catch (_) {}
        }
      }

      if (fullReply.isNotEmpty && !_isCancelled) {
        history.add({'role': 'model', 'parts': [{'text': fullReply.toString()}]});
      } else {
        history.removeLast();
      }
    } catch (e) {
      if (history.isNotEmpty && history.last['role'] == 'user') {
        history.removeLast();
      }
      if (!_isCancelled) rethrow;
    } finally {
      // Keep client open for connection reuse
      // client.close();
    }
  }

  Stream<String> _sendGroqStream(String userMessage, String sessionId, List<MessageModel> sessionMessages) async* {
    final history = _groqHistories.putIfAbsent(sessionId, () => []);
    final model = ApiConfig.groqModel;

    for (final msg in sessionMessages) {
      if (msg.content.isNotEmpty) {
        final role = msg.role == MessageRole.user ? 'user' : 'assistant';
        history.add({'role': role, 'content': msg.content});
      }
    }

    history.add({'role': 'user', 'content': userMessage});

    final url = Uri.parse('${ApiConfig.groqBaseUrl}/chat/completions');
    // Use shared client for connection pooling
    // final client = http.Client();
    final StringBuffer fullReply = StringBuffer();

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
      };

      final body = jsonEncode({
        'model': model,
        'messages': history,
        'temperature': 0.7,
        'max_tokens': 1024,
        'stream': true,
      });

      final streamedResponse = await _client.send(
        http.Request('POST', url)
          ..headers.addAll(headers)
          ..body = body,
      ).timeout(const Duration(seconds: 30));

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        history.removeLast();
        throw Exception('Groq API error ${streamedResponse.statusCode}: $errorBody');
      }

      String leftover = '';
      await for (final raw in streamedResponse.stream.transform(utf8.decoder)) {
        if (_isCancelled) break;

        final combined = leftover + raw;
        leftover = '';
        final lines = combined.split('\n');

        for (int i = 0; i < lines.length; i++) {
          if (_isCancelled) break;

          final line = lines[i].trim();
          if (i == lines.length - 1 && !combined.endsWith('\n')) {
            leftover = lines[i];
            continue;
          }
          if (!line.startsWith('data: ')) continue;
          final jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

          try {
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final content = data['choices']?[0]?['delta']?['content'] as String?;
            if (content != null) {
              fullReply.write(content);
              yield content;
            }
          } catch (_) {}
        }
      }

      if (fullReply.isNotEmpty && !_isCancelled) {
        history.add({'role': 'assistant', 'content': fullReply.toString()});
      } else {
        history.removeLast();
      }
    } catch (e) {
      if (history.isNotEmpty && history.last['role'] == 'user') {
        history.removeLast();
      }
      if (!_isCancelled) rethrow;
    } finally {
      // Keep client open for connection reuse
      // client.close();
    }
  }

  void clearHistory(String sessionId) {
    _histories.remove(sessionId);
    _groqHistories.remove(sessionId);
  }

  void clearAllHistories() {
    _histories.clear();
    _groqHistories.clear();
  }

  Future<bool> isOllamaRunning() async {
    if (ApiConfig.hasGeminiKey) {
      try {
        final baseUrl = ApiConfig.geminiBaseUrl.split(':generateContent').first;
        final url = Uri.parse('$baseUrl?key=${ApiConfig.geminiApiKey}');
        final response = await http.get(url).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) return true;
      } catch (_) {}
    }

    if (ApiConfig.hasGroqKey) {
      try {
        final url = Uri.parse('${ApiConfig.groqBaseUrl}/models');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer ${ApiConfig.groqApiKey}'},
        ).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) return true;
      } catch (_) {}
    }

    return false;
  }
}
