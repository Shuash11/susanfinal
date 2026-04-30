// ============================================================
// FILE: chat_widgets.dart
// DESC: Small reusable widgets shared across the chat screens:
//       _ChatBubble, _Avatar, _TypingIndicator, _SuggestionChip,
//       _ErrorBanner, _InputBar, _AppBarTitle, _ActiveChatTitle.
// ============================================================

import 'package:flutter/material.dart';
import 'message_model.dart';
import 'chatmodel.dart';
import 'spash_screen.dart';
import 'chatservice.dart';

// ── Color constants ───────────────────────────────────────────
const Color kBg = Color(0xFF0D1117);
const Color kSurface = Color(0xFF161B22);
const Color kCard = Color(0xFF21262D);
const Color kAccent = Color(0xFF00D4AA);
const Color kUserBubble = Color(0xFF1F6FEB);
const Color kTextPri = Color(0xFFE6EDF3);
const Color kTextSec = Color(0xFF8B949E);
const Color kBorder = Color(0xFF30363D);

// ── AppBarTitle (dashboard mode) ──────────────────────────────
class AppBarTitle extends StatelessWidget {
  final bool isConnected;
  const AppBarTitle({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: kAccent, width: 1.5),
          ),
          child: const Icon(Icons.school_rounded, size: 20, color: kAccent),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('StudyBuddy',
                style: TextStyle(
                  color: kTextPri,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                )),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isConnected ? 'AI Connected' : 'AI Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: isConnected ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ── ActiveChatTitle (when a session is open) ──────────────────
class ActiveChatTitle extends StatelessWidget {
  final ChatSession session;
  const ActiveChatTitle({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final msgCount = session.messages.where((m) => !m.isLoading).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(session.name,
            style: const TextStyle(
              color: kTextPri,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            )),
        Text('$msgCount messages',
            style: const TextStyle(color: kTextSec, fontSize: 11)),
      ],
    );
  }
}

// ── ChatBubble ────────────────────────────────────────────────
class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final ChatViewModel vm;
  const ChatBubble({super.key, required this.message, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const BubbleAvatar(isUser: false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress:
                  message.isLoading ? null : () => _showDeleteSheet(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? kUserBubble : kCard,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: message.isLoading && message.content.isEmpty
                    ? const TypingIndicator() // Waiting — show dots
                    : message.isLoading && message.content.isNotEmpty
                        ? Text(
                            // Streaming — show growing text
                            message.content,
                            style: const TextStyle(
                                color: kTextPri, fontSize: 14.5, height: 1.5),
                          )
                        : SelectableText(
                            // Done — show final text
                            message.content,
                            style: const TextStyle(
                                color: kTextPri, fontSize: 14.5, height: 1.5),
                          ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const BubbleAvatar(isUser: true),
          ],
        ],
      ),
    );
  }

  void _showDeleteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              title: const Text('Delete message',
                  style: TextStyle(color: kTextPri)),
              onTap: () {
                Navigator.pop(context);
                vm.deleteMessage(message.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: kTextSec),
              title: const Text('Cancel', style: TextStyle(color: kTextSec)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── BubbleAvatar ──────────────────────────────────────────────
class BubbleAvatar extends StatelessWidget {
  final bool isUser;
  const BubbleAvatar({super.key, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? kUserBubble.withValues(alpha: 0.3)
            : kAccent.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: isUser ? kUserBubble : kAccent, width: 1),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.school_rounded,
        size: 16,
        color: isUser ? kTextPri : kAccent,
      ),
    );
  }
}

// ── TypingIndicator ───────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500)),
    );
    _anims = _controllers
        .map((c) => Tween<double>(begin: 0.3, end: 1).animate(c))
        .toList();
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return FadeTransition(
          opacity: _anims[i],
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration:
                const BoxDecoration(color: kAccent, shape: BoxShape.circle),
          ),
        );
      }),
    );
  }
}

// ── SuggestionChip ────────────────────────────────────────────
class SuggestionChip extends StatelessWidget {
  final String text;
  const SuggestionChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final clean = text.replaceAll(RegExp(r'[^\w\s?,!.]'), '').trim();
        ChangeNotifierProvider.of<ChatViewModel>(context).sendMessage(clean);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(text,
                    style: const TextStyle(color: kTextPri, fontSize: 14))),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: kAccent),
          ],
        ),
      ),
    );
  }
}

// ── ErrorBanner ───────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  IconData _getIcon() {
    final lower = message.toLowerCase();
    if (lower.contains('limit') ||
        lower.contains('quota') ||
        lower.contains('rate')) {
      return Icons.hourglass_empty_rounded;
    }
    if (lower.contains('busy') ||
        lower.contains('internal') ||
        lower.contains('try again later')) {
      return Icons.sync_problem_rounded;
    }
    if (lower.contains('internet') ||
        lower.contains('connect') ||
        lower.contains('network')) {
      return Icons.wifi_off_rounded;
    }
    if (lower.contains('api key') || lower.contains('unauthorized')) {
      return Icons.key_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(_getIcon(), size: 18, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 13))),
        ],
      ),
    );
  }
}

// ── InputBar ──────────────────────────────────────────────────
class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback? onStop;
  final ChatProvider? selectedProvider;
  final ValueChanged<ChatProvider>? onProviderChanged;

  const InputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    this.onStop,
    this.selectedProvider,
    this.onProviderChanged,
  });

  IconData _getProviderIcon(ChatProvider? provider) {
    switch (provider) {
      case ChatProvider.studyBuddyFast:
        return Icons.bolt_rounded;
      case ChatProvider.studyBuddyJuniorCoder:
        return Icons.code_rounded;
      case ChatProvider.studyBuddyGeneralTask:
        return Icons.task_alt_rounded;
      case ChatProvider.studyBuddyThinker:
      default:
        return Icons.psychology_rounded;
    }
  }

  String _getProviderName(ChatProvider? provider) {
    switch (provider) {
      case ChatProvider.studyBuddyFast:
        return 'Fast';
      case ChatProvider.studyBuddyJuniorCoder:
        return 'Junior Coder';
      case ChatProvider.studyBuddyGeneralTask:
        return 'General';
      case ChatProvider.studyBuddyThinker:
      default:
        return 'Thinker';
    }
  }

  void _showProviderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select AI Model',
                  style: TextStyle(
                    color: kTextPri,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            _ProviderOption(
              icon: Icons.psychology_rounded,
              title: 'Study Buddy Thinker',
              subtitle: 'Thinks & executes at intermediate level',
              isSelected: selectedProvider == ChatProvider.studyBuddyThinker,
              onTap: () {
                onProviderChanged?.call(ChatProvider.studyBuddyThinker);
                Navigator.pop(context);
              },
            ),
            _ProviderOption(
              icon: Icons.bolt_rounded,
              title: 'Study Buddy Fast',
              subtitle: 'Faster Response',
              isSelected: selectedProvider == ChatProvider.studyBuddyFast,
              onTap: () {
                onProviderChanged?.call(ChatProvider.studyBuddyFast);
                Navigator.pop(context);
              },
            ),
            _ProviderOption(
              icon: Icons.code_rounded,
              title: 'Study Buddy Junior Coder',
              subtitle: 'Good for ComSci simple tasks',
              isSelected: selectedProvider == ChatProvider.studyBuddyJuniorCoder,
              onTap: () {
                onProviderChanged?.call(ChatProvider.studyBuddyJuniorCoder);
                Navigator.pop(context);
              },
            ),
            _ProviderOption(
              icon: Icons.task_alt_rounded,
              title: 'Study Buddy General',
              subtitle: 'General questions',
              isSelected: selectedProvider == ChatProvider.studyBuddyGeneralTask,
              onTap: () {
                onProviderChanged?.call(ChatProvider.studyBuddyGeneralTask);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          // Model selector button
          GestureDetector(
            onTap: isLoading ? null : () => _showProviderSelector(context),
            child: Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getProviderIcon(selectedProvider),
                    color: kAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _getProviderName(selectedProvider),
                      style: const TextStyle(
                        color: kTextPri,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: kTextSec,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: kTextPri, fontSize: 14.5),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask me a study question...',
                  hintStyle: TextStyle(color: kTextSec, fontSize: 14.5),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isLoading ? onStop : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLoading ? Colors.redAccent : kAccent,
                shape: BoxShape.circle,
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: kAccent.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: isLoading
                  ? const Icon(Icons.stop_rounded, color: Colors.white, size: 20)
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? kAccent.withValues(alpha: 0.2) : kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? kAccent : kBorder,
          ),
        ),
        child: Icon(icon, color: isSelected ? kAccent : kTextSec),
      ),
      title: Text(title,
          style: TextStyle(
            color: isSelected ? kAccent : kTextPri,
            fontWeight: FontWeight.w600,
          )),
      subtitle:
          Text(subtitle, style: const TextStyle(color: kTextSec, fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: kAccent)
          : null,
      onTap: onTap,
    );
  }
}
