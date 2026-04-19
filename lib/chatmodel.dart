// ============================================================
// FILE: chatmodel.dart
// DESC: ViewModel for multi-session chat. Each ChatSession
//       holds its own list of messages. The user can create,
//       switch, and delete sessions.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_model.dart';
import 'chatservice.dart';
import 'chat_repository.dart';

// ── ChatSession ───────────────────────────────────────────────
class ChatSession {
  final String id;
  String name;
  final List<MessageModel> messages;
  final DateTime createdAt;

  // Direct mutable fields — no more static extension maps
  bool isLoading = false;
  String? errorMessage;

  ChatSession({
    required this.id,
    required this.name,
    List<MessageModel>? messages,
    DateTime? createdAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get hasMessages => messages.isNotEmpty;

  String get preview {
    final last = messages.lastWhere(
      (m) => !m.isLoading,
      orElse: () => MessageModel.fromUser(''),
    );
    if (last.content.isEmpty) return 'No messages yet';
    return last.content.length > 60
        ? '${last.content.substring(0, 60)}…'
        : last.content;
  }
}

// ── ChatViewModel ─────────────────────────────────────────────
class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final ChatRepository _chatRepository = ChatRepository();

  bool _isLoadingSessions = true;
  bool get isLoadingSessions => _isLoadingSessions;

  bool _isGeminiConnected = false;
  bool get isGeminiConnected => _isGeminiConnected;
  bool get isOllamaConnected => _isGeminiConnected;

  ChatProvider _selectedProvider = ChatProvider.studyBuddyGeneralTask;
  ChatProvider get selectedProvider => _selectedProvider;

  final List<ChatSession> _sessions = [];
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  ChatSession? _activeSession;
  ChatSession? get activeSession => _activeSession;

  bool get hasActiveSession => _activeSession != null;

  List<MessageModel> get messages =>
      _activeSession == null ? [] : List.unmodifiable(_activeSession!.messages);

  // These now read directly from the session's own fields
  bool get isLoading => _activeSession?.isLoading ?? false;
  String? get errorMessage => _activeSession?.errorMessage;
  bool get hasMessages => _activeSession?.hasMessages ?? false;

  static const int chatExpiryDays = 2;

  Future<void> initialize() async {
    _isLoadingSessions = true;
    notifyListeners();

    // Wait for auth to be ready
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.authStateChanges().first
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // Timeout or error - proceed anyway
    }

    _isGeminiConnected = await _chatService.isOllamaRunning();

    final savedSessions = await _chatRepository.loadSessions();

    // Delete sessions older than 2 days
    final now = DateTime.now();
    final expiredSessions = <ChatSession>[];
    for (final session in savedSessions) {
      final age = now.difference(session.createdAt).inDays;
      if (age >= chatExpiryDays) {
        expiredSessions.add(session);
        _chatRepository.deleteSession(session.id);
      }
    }

    // Keep only non-expired sessions
    _sessions.addAll(savedSessions.where((s) => !expiredSessions.contains(s)));

    _isLoadingSessions = false;
    notifyListeners();
  }

  void setProvider(ChatProvider provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  void stopGeneration() {
    _chatService.cancelCurrentRequest();
    if (_activeSession != null) {
      _activeSession!.isLoading = false;
      _activeSession!.messages.removeWhere((m) => m.isLoading);
      notifyListeners();
    }
  }

  // ── Session management ───────────────────────────────────────

  ChatSession createSession(String name) {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'New Chat' : name.trim(),
    );
    _sessions.insert(0, session);
    _activeSession = session;
    notifyListeners();

    // Save new session to Firebase
    _chatRepository.saveSession(session);

    return session;
  }

  void openSession(String id) {
    _activeSession = _sessions.firstWhere((s) => s.id == id);
    notifyListeners();
  }

  void closeSession() {
    _activeSession = null;
    notifyListeners();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSession?.id == id) _activeSession = null;
    _chatService.clearHistory(sessionId: id);
    _chatRepository.deleteSession(id);
    notifyListeners();
  }

  // ── Messaging ────────────────────────────────────────────────

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _activeSession == null) return;
    if (_activeSession!.isLoading) return;

    final session = _activeSession!;
    session.errorMessage = null;

    // 1. Add the user message
    final userMessage = MessageModel.fromUser(content.trim());
    session.messages.add(userMessage);

    // 2. Add a placeholder loading bubble with a known id
    final String loadingId = 'loading_${DateTime.now().millisecondsSinceEpoch}';
    session.messages.add(MessageModel(
      id: loadingId,
      content: '',
      role: MessageRole.bot,
      timestamp: DateTime.now(),
      isLoading: true,
    ));

    session.isLoading = true;
    notifyListeners();

    final StringBuffer streamBuffer = StringBuffer();

    try {
      await for (final chunk in _chatService.sendMessageStream(content.trim(),
          sessionId: session.id, sessionMessages: session.messages, preferredProvider: _selectedProvider)) {
        streamBuffer.write(chunk);

        // Look up the bubble fresh on every chunk using the stable loadingId
        final liveIndex = session.messages.indexWhere((m) => m.id == loadingId);

        if (liveIndex != -1) {
          // Show streaming text — still marked isLoading: true so dots → text transition works
          session.messages[liveIndex] = MessageModel(
            id: loadingId,
            content: streamBuffer.toString(),
            role: MessageRole.bot,
            timestamp: session.messages[liveIndex].timestamp,
            isLoading: true,
          );
          notifyListeners();
        }
      }

      // ── Stream finished — finalize the bubble ──────────────
      session.isLoading = false;

      final finalIndex = session.messages.indexWhere((m) => m.id == loadingId);

      if (finalIndex != -1) {
        if (streamBuffer.isEmpty) {
          // Bot returned nothing — silently remove the bubble
          session.messages.removeAt(finalIndex);
        } else {
          // Stamp final message with isLoading: FALSE — this stops the dots
          session.messages[finalIndex] = MessageModel(
            id: loadingId,
            content: streamBuffer.toString(),
            role: MessageRole.bot,
            timestamp: session.messages[finalIndex].timestamp,
            isLoading: false,
          );
        }
      } else {
        // Safety net — remove any bubble still marked as loading
        session.messages.removeWhere((m) => m.isLoading);
      }

      notifyListeners();

      // Save to Firebase after message completes
      await _chatRepository.saveSession(session);
    } catch (error) {
      session.isLoading = false;
      session.messages.removeWhere((m) => m.isLoading);
      session.errorMessage = _parseError(error.toString());
      notifyListeners();
    }
  }

  void deleteMessage(String messageId) {
    _activeSession?.messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  void deleteMessageFromSession(String sessionId, String messageId) {
    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => _activeSession!,
    );
    session.messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  void clearChat() {
    if (_activeSession == null) return;
    _activeSession!.messages.clear();
    _activeSession!.errorMessage = null;
    _chatService.clearHistory(sessionId: _activeSession!.id);
    notifyListeners();
  }

  String _parseError(String error) {
    final err = error.toLowerCase();
    if (err.contains('429') ||
        err.contains('resource_exhausted') ||
        err.contains('quota') ||
        err.contains('rate limit')) {
      return 'Rate limit reached. Trying alternative AI...';
    }
    if (err.contains('connection refused') ||
        err.contains('socketexception') ||
        err.contains('connection failed') ||
        err.contains('failed to host')) {
      return 'Cannot connect to AI. Check your internet.';
    }
    if (err.contains('timeout')) {
      return 'Request timed out. AI might be busy. Try again.';
    }
    if (err.contains('500') ||
        err.contains('503') ||
        err.contains('internal')) {
      return 'AI is busy at the moment. Please try again later.';
    }
    if (err.contains('400') || err.contains('bad request')) {
      return 'Invalid request. Please try a different question.';
    }
    if (err.contains('401') ||
        err.contains('unauthorized') ||
        err.contains('api key')) {
      return 'API key issue. Check your .env file.';
    }
    if (err.contains('all ai providers failed') || err.contains('no ai provider available')) {
      return 'AI unavailable. Try switching to another model.';
    }
    if (err.contains('gemini')) {
      return 'Thinker unavailable. Try Fast model.';
    }
    if (err.contains('groq')) {
      return 'Fast/Junior Coder unavailable. Try Thinker instead.';
    }
    return 'Something went wrong: ${error.length > 50 ? error.substring(0, 50) : error}';
  }
}
