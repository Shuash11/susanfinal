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

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _sessionsCol =>
      _db.collection('users').doc(_uid).collection('sessions');

  CollectionReference _messagesCol(String sessionId) =>
      _sessionsCol.doc(sessionId).collection('messages');

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
          'sessionId': session.id,
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      // Silent fail
    }
  }

  Future<List<ChatSession>> loadSessions({int limit = 10, int offset = 0}) async {
    if (_uid == null) return [];

    try {
      final allSnap = await _sessionsCol
          .orderBy('createdAt', descending: true)
          .get();

      if (allSnap.docs.isEmpty) return [];

      final allDocs = allSnap.docs;
      if (offset >= allDocs.length) return [];

      final endIndex = (offset + limit) > allDocs.length 
          ? allDocs.length 
          : offset + limit;
      final snapDocs = allDocs.sublist(offset, endIndex);

      final sessions = <ChatSession>[];
      final sessionIds = <String>[];

      for (final doc in snapDocs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        
        final session = ChatSession(
          id: data['id'] as String,
          name: data['name'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );
        sessions.add(session);
        sessionIds.add(session.id);
      }

      final messagesBySession = <String, List<MessageModel>>{};
      for (final sessionId in sessionIds) {
        final msgSnap = await _messagesCol(sessionId).get();
        final messages = <MessageModel>[];
        for (final msgDoc in msgSnap.docs) {
          final m = msgDoc.data() as Map<String, dynamic>?;
          if (m == null) continue;
          messages.add(MessageModel(
            id: m['id'] as String,
            content: m['content'] as String,
            role: m['role'] == 'user' ? MessageRole.user : MessageRole.bot,
            timestamp: DateTime.parse(m['timestamp'] as String),
          ));
        }
        messagesBySession[sessionId] = messages;
      }

      for (final session in sessions) {
        session.messages.addAll(messagesBySession[session.id] ?? []);
      }

      return sessions;
    } catch (e) {
      return [];
    }
  }

  Future<int> getSessionCount() async {
    if (_uid == null) return 0;
    try {
      final snap = await _sessionsCol.get();
      return snap.docs.length;
    } catch (e) {
      return 0;
    }
  }

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

  Future<void> deleteMessage(String sessionId, String messageId) async {
    if (_uid == null) return;
    try {
      await _messagesCol(sessionId).doc(messageId).delete();
    } catch (e) {
      // Silent fail
    }
  }
}