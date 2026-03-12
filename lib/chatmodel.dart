import 'package:flutter/material.dart';
import 'message_model.dart';
import 'chatservice.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isOllamaConnected = false;
  String? _errorMessage;
  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isOllamaConnected => _isOllamaConnected;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  Future<void> initialize() async {
    _isOllamaConnected = await _chatService.isOllamaRunning();
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isLoading) return;

    _errorMessage = null;

    final userMessage = MessageModel.fromUser(content.trim());
    _messages.add(userMessage);

    final loadingMessage = MessageModel.fromBot('', isLoading: true);
    _messages.add(loadingMessage);

    _isLoading = true;
    notifyListeners();

    try {
      final reply = await _chatService.sendMessage(content.trim());

      final index = _messages.indexWhere((m) => m.id == loadingMessage.id);
      if (index != -1) {
        _messages[index] = loadingMessage.copyWith(
          content: reply,
          isLoading: false,
        );
      }
    } catch (error) {
      _messages.removeWhere((m) => m.id == loadingMessage.id);
      _errorMessage = _parseError(error.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _errorMessage = null;
    _chatService.clearHistory();
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('Connection refused') ||
        error.contains('SocketException')) {
      return 'Cannot connect to Ollama. Make sure it is running on your PC.';
    }
    if (error.contains('timeout')) {
      return 'Request timed out. Ollama might be busy or slow.';
    }
    return 'Something went wrong. Please try again.';
  }
}
