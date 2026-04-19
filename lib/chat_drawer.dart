// ============================================================
// FILE: chat_drawer.dart
// DESC: Side drawer — chat session list + profile tile at bottom.
// ============================================================

import 'package:flutter/material.dart';
import 'chatmodel.dart';
import 'chat_widgets.dart';

// ── ChatDrawer ────────────────────────────────────────────────
class ChatDrawer extends StatelessWidget {
  final ChatViewModel vm;
  final String username;
  final VoidCallback onNewChat;
  final VoidCallback onProfile;
  final void Function(ChatSession) onSelectSession;
  final void Function(ChatSession) onDeleteSession;

  const ChatDrawer({
    super.key,
    required this.vm,
    required this.username,
    required this.onNewChat,
    required this.onProfile,
    required this.onSelectSession,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kSurface,
      child: Column(
        children: [
          _DrawerHeader(),
          _NewChatButton(onTap: onNewChat),
          if (vm.sessions.isNotEmpty)
            const _SectionLabel(label: 'RECENT CHATS'),
          Expanded(
            child: vm.isLoadingSessions
                ? const _LoadingDrawer()
                : vm.sessions.isEmpty
                    ? const _EmptyDrawer()
                    : _SessionList(
                        sessions: vm.sessions,
                        activeId: vm.activeSession?.id,
                        onSelect: onSelectSession,
                        onDelete: onDeleteSession,
                      ),
          ),
          // Profile tile pinned to the bottom
          _ProfileTile(username: username, onTap: onProfile),
        ],
      ),
    );
  }
}

// ── _DrawerHeader ─────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: kAccent, width: 1.5),
            ),
            child: const Icon(Icons.school_rounded, size: 20, color: kAccent),
          ),
          const SizedBox(width: 12),
          const Text(
            'StudyBuddy',
            style: TextStyle(
              color: kTextPri, fontSize: 18,
              fontWeight: FontWeight.bold, fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}

// ── _NewChatButton ────────────────────────────────────────────
class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: kAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kAccent.withValues(alpha: 0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_rounded, color: kAccent, size: 20),
              SizedBox(width: 10),
              Text('New Chat',
                  style: TextStyle(
                    color: kAccent, fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _SectionLabel ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: kTextSec, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ── _SessionList ──────────────────────────────────────────────
class _SessionList extends StatelessWidget {
  final List<ChatSession> sessions;
  final String? activeId;
  final void Function(ChatSession) onSelect;
  final void Function(ChatSession) onDelete;

  const _SessionList({
    required this.sessions,
    required this.activeId,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      itemCount: sessions.length,
      itemBuilder: (_, i) {
        final session = sessions[i];
        return _SessionTile(
          session: session,
          isActive: activeId == session.id,
          onTap: () => onSelect(session),
          onDelete: () => onDelete(session),
        );
      },
    );
  }
}

// ── _SessionTile ──────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? kAccent.withValues(alpha: 0.12)
              : kCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? kAccent.withValues(alpha: 0.5)
                : kBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 16, color: isActive ? kAccent : kTextSec),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? kAccent : kTextPri,
                      fontSize: 13.5, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kTextSec, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded,
                    size: 15, color: kTextSec.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _ProfileTile ──────────────────────────────────────────────
// Pinned at the bottom of the drawer. Shows avatar initials,
// username, and an arrow to open the profile screen.
class _ProfileTile extends StatelessWidget {
  final String username;
  final VoidCallback onTap;

  const _ProfileTile({required this.username, required this.onTap});

  String get _initials {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: kAccent, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: kAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextPri,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'View profile',
                      style: TextStyle(color: kTextSec, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: kTextSec, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _EmptyDrawer ──────────────────────────────────────────────
class _EmptyDrawer extends StatelessWidget {
  const _EmptyDrawer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 40, color: kAccent.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          const Text('No chats yet',
              style: TextStyle(color: kTextSec, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── _LoadingDrawer ─────────────────────────────────────────────
class _LoadingDrawer extends StatelessWidget {
  const _LoadingDrawer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: kAccent,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Loading chats...',
            style: TextStyle(color: kTextSec, fontSize: 13),
          ),
        ],
      ),
    );
  }
}