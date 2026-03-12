import 'package:flutter/material.dart';
import 'message_model.dart';
import 'chatmodel.dart';

class HistoryScreen extends StatelessWidget {
  // VM is passed directly — no provider wrapping needed.
  // This avoids any dispose/lifecycle issues when opening History multiple times.
  final ChatViewModel vm;
  const HistoryScreen({super.key, required this.vm});

  static const Color _bgColor = Color(0xFF0D1117);
  static const Color _surfaceColor = Color(0xFF161B22);
  static const Color _textPrimary = Color(0xFFE6EDF3);
  static const Color _borderColor = Color(0xFF30363D);

  @override
  Widget build(BuildContext context) {
    // Filter out any messages that are still loading (typing dots)
    final messages = vm.messages.where((m) => !m.isLoading).toList();

    return Scaffold(
      backgroundColor: _bgColor,

      // ── App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,

        // Bottom border line under the app bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _borderColor),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Chat History',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),

        actions: [
          // Badge showing how many messages are in this session
          _MessageCountBadge(count: messages.length),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────
      // Show empty state if there are no messages, otherwise show the list
      body: messages.isEmpty
          ? const _EmptyHistory()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _HistoryCard(
                message: messages[index],
                index: index,
              ),
            ),
    );
  }
}

// ── _MessageCountBadge ────────────────────────────────────────
// Shows "X messages" pill badge in the top-right of the app bar.
class _MessageCountBadge extends StatelessWidget {
  final int count;
  const _MessageCountBadge({required this.count});

  static const Color _accentColor = Color(0xFF00D4AA);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$count messages',
        style: const TextStyle(color: _accentColor, fontSize: 12),
      ),
    );
  }
}

// ── _HistoryCard ─────────────────────────────────────────────
// One card in the history list — shows who sent it,
// when it was sent, and the message text.
class _HistoryCard extends StatelessWidget {
  final MessageModel message;
  final int index;

  const _HistoryCard({required this.message, required this.index});

  static const Color _cardColor = Color(0xFF21262D);
  static const Color _accentColor = Color(0xFF00D4AA);
  static const Color _userColor = Color(0xFF1F6FEB);
  static const Color _textPrimary = Color(0xFFE6EDF3);
  static const Color _textSecondary = Color(0xFF8B949E);
  static const Color _borderColor = Color(0xFF30363D);

  bool get _isUser => message.isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isUser
              ? _userColor.withValues(alpha: 0.3)
              : _accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoleAvatar(isUser: _isUser),
              const SizedBox(width: 10),
              Text(
                _isUser ? 'You' : 'StudyBuddy',
                style: TextStyle(
                  color: _isUser ? _userColor : _accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(message.timestamp),
                style: const TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(color: _borderColor, height: 1),
          const SizedBox(height: 10),

          Text(
            message.content,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// ── _RoleAvatar ───────────────────────────────────────────────
class _RoleAvatar extends StatelessWidget {
  final bool isUser;
  const _RoleAvatar({required this.isUser});

  static const Color _accentColor = Color(0xFF00D4AA);
  static const Color _userColor = Color(0xFF1F6FEB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isUser
            ? _userColor.withValues(alpha: 0.15)
            : _accentColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.school_rounded,
        size: 15,
        color: isUser ? _userColor : _accentColor,
      ),
    );
  }
}

// ── _EmptyHistory ─────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  static const Color _accentColor = Color(0xFF00D4AA);
  static const Color _textPrimary = Color(0xFFE6EDF3);
  static const Color _textSecondary = Color(0xFF8B949E);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: _accentColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No history yet',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation and your\nquestions will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}