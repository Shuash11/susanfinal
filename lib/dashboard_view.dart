// ============================================================
// FILE: dashboard_view.dart
// DESC: Shown when no chat session is active.
//       Displays a welcome banner, a "New Chat" CTA, and
//       cards for every existing session (recent chats).
// ============================================================

import 'package:flutter/material.dart';
import 'chatmodel.dart';
import 'chat_widgets.dart';

// ── DashboardView ─────────────────────────────────────────────
class DashboardView extends StatelessWidget {
  final ChatViewModel vm;
  final VoidCallback onNewChat;
  final void Function(ChatSession) onSelectSession;
  final void Function(ChatSession) onDeleteSession;

  const DashboardView({
    super.key,
    required this.vm,
    required this.onNewChat,
    required this.onSelectSession,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingSessions) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kAccent),
            SizedBox(height: 16),
            Text(
              'Loading your chats...',
              style: TextStyle(color: kTextSec, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeBanner(onNewChat: onNewChat),
          const SizedBox(height: 28),
          vm.sessions.isNotEmpty
              ? _RecentChatsSection(
                  sessions: vm.sessions,
                  onSelect: onSelectSession,
                  onDelete: onDeleteSession,
                )
              : const _NoChatsHint(),
        ],
      ),
    );
  }
}

// ── _WelcomeBanner ────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final VoidCallback onNewChat;
  const _WelcomeBanner({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: kAccent, width: 2),
            ),
            child: const Icon(Icons.school_rounded, size: 34, color: kAccent),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to StudyBuddy!',
            style: TextStyle(
              color: kTextPri,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start a new chat or pick up where you left off.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSec, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onNewChat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('New Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _RecentChatsSection ───────────────────────────────────────
class _RecentChatsSection extends StatelessWidget {
  final List<ChatSession> sessions;
  final void Function(ChatSession) onSelect;
  final void Function(ChatSession) onDelete;

  const _RecentChatsSection({
    required this.sessions,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Recent Chats',
                style: TextStyle(
                  color: kTextPri,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${sessions.length}',
                  style: const TextStyle(color: kAccent, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sessions.map((s) => SessionCard(
              session: s,
              onTap: () => onSelect(s),
              onDelete: () => onDelete(s),
            )),
      ],
    );
  }
}

// ── SessionCard ───────────────────────────────────────────────
// Public so HomeScreen can also use it if needed.
class SessionCard extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        dt.day == now.day && dt.month == now.month && dt.year == now.year;
    if (sameDay) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return 'Today $h:$m';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final msgCount = session.messages.where((m) => !m.isLoading).length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: kAccent.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: kAccent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextPri,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Text(session.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kTextSec, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: kTextSec),
                      const SizedBox(width: 3),
                      Text(_formatDate(session.createdAt),
                          style:
                              const TextStyle(color: kTextSec, fontSize: 11)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: kAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$msgCount msgs',
                            style: const TextStyle(
                                color: kAccent, fontSize: 10.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _NoChatsHint ──────────────────────────────────────────────
class _NoChatsHint extends StatelessWidget {
  const _NoChatsHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.forum_outlined,
              size: 48, color: kAccent.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
          const Text('No chats yet',
              style: TextStyle(
                color: kTextPri,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          const Text('Tap "New Chat" to get started!',
              style: TextStyle(color: kTextSec, fontSize: 13)),
        ],
      ),
    );
  }
}
