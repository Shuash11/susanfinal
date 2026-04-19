// lib/chat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatmodel.dart';
import 'message_model.dart';

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Returns the current user's UID or null if not logged in
  String? get _uid => _auth.currentUser?.uid;

  // ── Collection paths ───────────────────────────────────────

  CollectionReference get _sessionsCol =>
      _db.collection('users').doc(_uid).collection('sessions');

  CollectionReference _messagesCol(String sessionId) =>
      _sessionsCol.doc(sessionId).collection('messages');

  // ── Save a full session (upsert) ───────────────────────────

  Future<void> saveSession(ChatSession session) async {
    if (_uid == null) return;
    try {
      await _sessionsCol.doc(session.id).set({
        'id': session.id,
        'name': session.name,
        'createdAt': session.createdAt.toIso8601String(),
        'preview': session.preview,
        'messageCount': session.messages.where((m) => !m.isLoading).length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final batch = _db.batch();
      for (final msg in session.messages.where((m) => !m.isLoading)) {
        final ref = _messagesCol(session.id).doc(msg.id);
        batch.set(ref, {
          'id': msg.id,
          'content': msg.content,
          'role': msg.isUser ? 'user' : 'bot',
          'timestamp': msg.timestamp.toIso8601String(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      // Silent fail
    }
  }

  // ── Load all sessions for current user ─────────────────────

  Future<List<ChatSession>> loadSessions() async {
    if (_uid == null) {
      return [];
    }
    try {
      final snap = await _sessionsCol.get();

      final sessions = <ChatSession>[];
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        final session = ChatSession(
          id: data['id'] as String,
          name: data['name'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );

        final msgSnap = await _messagesCol(session.id).get();

        for (final msgDoc in msgSnap.docs) {
          final m = msgDoc.data() as Map<String, dynamic>;
          session.messages.add(MessageModel(
            id: m['id'] as String,
            content: m['content'] as String,
            role: m['role'] == 'user' ? MessageRole.user : MessageRole.bot,
            timestamp: DateTime.parse(m['timestamp'] as String),
          ));
        }

        sessions.add(session);
      }
      return sessions;
    } catch (e) {
      return [];
    }
  }

  // ── Delete a session and all its messages ──────────────────

  Future<void> deleteSession(String sessionId) async {
    if (_uid == null) return;
    try {
      final msgs = await _messagesCol(sessionId).get();
      final batch = _db.batch();
      for (final doc in msgs.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_sessionsCol.doc(sessionId));
      await batch.commit();
    } catch (e) {
      // Silent fail
    }
  }

  // ── Delete one message ────────────────────────────────────

  Future<void> deleteMessage(String sessionId, String messageId) async {
    if (_uid == null) return;
    try {
      await _messagesCol(sessionId).doc(messageId).delete();
    } catch (e) {
      // Silent fail
    }
  }
}