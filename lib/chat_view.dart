// ============================================================
// FILE: chat_view.dart
// DESC: The active chat screen body — message list, empty state,
//       error banner, and input bar. Shown when a session is open.
// ============================================================

import 'package:flutter/material.dart';
import 'chatmodel.dart';
import 'chat_widgets.dart';

// ── ChatView ──────────────────────────────────────────────────
class ChatView extends StatelessWidget {
  final ChatViewModel vm;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final VoidCallback onSend;

  const ChatView({
    super.key,
    required this.vm,
    required this.scrollController,
    required this.inputController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: vm.hasMessages
              ? _MessageList(
                  vm: vm,
                  scrollController: scrollController,
                )
              : const _EmptySessionState(),
        ),
        if (vm.errorMessage != null) ErrorBanner(message: vm.errorMessage!),
        InputBar(
          controller: inputController,
          isLoading: vm.isLoading,
          onSend: onSend,
          onStop: () => vm.stopGeneration(),
          selectedProvider: vm.selectedProvider,
          onProviderChanged: (provider) => vm.setProvider(provider),
        ),
      ],
    );
  }
}

// ── _MessageList ──────────────────────────────────────────────
class _MessageList extends StatelessWidget {
  final ChatViewModel vm;
  final ScrollController scrollController;

  const _MessageList({
    required this.vm,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final messages = vm.messages;
    return ListView.builder(
      key: PageStorageKey('chat_list_${messages.length}'),
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (_, index) => ChatBubble(
        key: ObjectKey(messages[index]),
        message: messages[index],
        vm: vm,
      ),
    );
  }
}

// ── _EmptySessionState ────────────────────────────────────────
// Shown inside an open session before any messages are sent.
class _EmptySessionState extends StatelessWidget {
  const _EmptySessionState();

  static const List<String> _suggestions = [
    '📐 How do I solve quadratic equations?',
    '📝 Explain the parts of speech in English',
    '💻 What is a for loop in programming?',
    '🔬 What is photosynthesis?',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: kAccent.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 38, color: kAccent),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hello, I\'m StudyBuddy! 👋',
            style: TextStyle(
              color: kTextPri,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about your studies!\nI\'m here to help you learn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSec, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Try asking:',
                style: TextStyle(
                  color: kTextSec,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ),
          const SizedBox(height: 12),
          ..._suggestions.map((t) => SuggestionChip(text: t)),
        ],
      ),
    );
  }
}
