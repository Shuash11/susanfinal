// ============================================================
// FILE: profile_screen.dart
// DESC: User profile screen. Shows avatar, username, account
//       stats (total chats & messages), and a logout button.
// ============================================================

import 'package:flutter/material.dart';
import 'chat_widgets.dart';
import 'chatmodel.dart';
import 'user_repository.dart';
import 'login.dart';

class ProfileScreen extends StatelessWidget {
  final ChatViewModel vm;
  final String username;

  const ProfileScreen({
    super.key,
    required this.vm,
    required this.username,
  });

  // ── Stats ────────────────────────────────────────────────────
  int get _totalChats => vm.sessions.length;

  int get _totalMessages => vm.sessions.fold(0, (sum, s) {
        return sum + s.messages.where((m) => !m.isLoading).length;
      });

  int get _userMessages => vm.sessions.fold(0, (sum, s) {
        return sum + s.messages.where((m) => m.isUser && !m.isLoading).length;
      });

  // ── Avatar initials ──────────────────────────────────────────
  String get _initials {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kTextPri),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: kTextPri,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _AvatarCard(initials: _initials, username: username),
            const SizedBox(height: 24),
            _StatsRow(
              totalChats: _totalChats,
              totalMessages: _totalMessages,
              userMessages: _userMessages,
            ),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'ACCOUNT'),
            const SizedBox(height: 10),
            _ProfileTile(
              icon: Icons.person_outline_rounded,
              label: 'Username',
              value: username,
            ),
            const SizedBox(height: 8),
            _ProfileTile(
              icon: Icons.lock_outline_rounded,
              label: 'Password',
              value: '••••••••',
            ),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'SESSION'),
            const SizedBox(height: 10),
            _LogoutButton(
              onLogout: () => _handleLogout(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: kTextPri, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: kTextSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: kTextSec)),
          ),
          ElevatedButton(
            onPressed: () {
              UserRepository().logout();
              // Pop dialog, pop profile, replace home with login
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginScreen(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Log Out',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── _AvatarCard ───────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  final String initials;
  final String username;
  const _AvatarCard({required this.initials, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          // Avatar circle with initials
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: kAccent, width: 2.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: kAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            username,
            style: const TextStyle(
              color: kTextPri,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kAccent.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'Student',
              style: TextStyle(color: kAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _StatsRow ─────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int totalChats;
  final int totalMessages;
  final int userMessages;

  const _StatsRow({
    required this.totalChats,
    required this.totalMessages,
    required this.userMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          icon: Icons.forum_outlined,
          value: '$totalChats',
          label: 'Chats',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon: Icons.chat_bubble_outline_rounded,
          value: '$totalMessages',
          label: 'Messages',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon: Icons.question_answer_outlined,
          value: '$userMessages',
          label: 'Questions',
        ),
      ],
    );
  }
}

// ── _StatBox ──────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: kAccent, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: kTextPri,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: kTextSec, fontSize: 11.5),
            ),
          ],
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: kTextSec,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── _ProfileTile ──────────────────────────────────────────────
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: kTextSec, size: 19),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(color: kTextSec, fontSize: 13.5),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: kTextPri,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── _LogoutButton ─────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.35)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 19),
            SizedBox(width: 10),
            Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}