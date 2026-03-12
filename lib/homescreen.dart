// ============================================================
// FILE: homescreen.dart
// DESC: The main chat screen where students talk to StudyBuddy.
//       It shows messages, handles user input, and displays
//       errors or an empty state when there are no messages yet.
// ============================================================

import 'package:flutter/material.dart';
import 'message_model.dart';
import 'chatmodel.dart';
import 'spash_screen.dart';
import 'history.dart';

// ── HomeScreen ────────────────────────────────────────────────
// This is a StatefulWidget because it manages a scroll controller
// and a text input controller that need to be disposed properly.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // ── Controllers ─────────────────────────────────────────────
  final TextEditingController _inputController  = TextEditingController();
  final ScrollController      _scrollController = ScrollController();

  // ── Colors ──────────────────────────────────────────────────
  static const Color _bgColor       = Color(0xFF0D1117);
  static const Color _surfaceColor  = Color(0xFF161B22);
  static const Color _cardColor     = Color(0xFF21262D);

  static const Color _textPrimary   = Color(0xFFE6EDF3);
  static const Color _textSecondary = Color(0xFF8B949E);
  static const Color _borderColor   = Color(0xFF30363D);

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── _scrollToBottom ─────────────────────────────────────────
  // Smoothly scrolls the chat list to the latest message.
  // We use addPostFrameCallback so it runs AFTER the new message
  // has been drawn on screen (not before).
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  // ── _handleSend ─────────────────────────────────────────────
  // Called when the student taps the Send button.
  // Reads the input, clears the field, sends the message,
  // then scrolls down to show the new bubble.
  void _handleSend(ChatViewModel vm) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    vm.sendMessage(text);
    _scrollToBottom();
  }

  // ── _showClearDialog ────────────────────────────────────────
  // Shows a confirmation dialog before clearing all messages.
  // We don't clear immediately so the student can cancel.
  void _showClearDialog(ChatViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Chat',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to clear all messages?',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () {
              vm.clearChat();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Get the shared ChatViewModel from the widget tree
    final vm = ChangeNotifierProvider.of<ChatViewModel>(context);

    // Auto-scroll when new messages arrive
    if (vm.hasMessages) _scrollToBottom();

    return SafeArea(
      child: Scaffold(
        backgroundColor: _bgColor,

        // ── App Bar ─────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: _surfaceColor,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _borderColor),
          ),
          title: _AppBarTitle(isConnected: vm.isOllamaConnected),
          actions: [
            // History button — opens the chat history screen
            IconButton(
              icon:    const Icon(Icons.history_rounded, color: _textSecondary),
              tooltip: 'View History',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // Pass vm directly — no provider wrapper needed.
                  // Avoids double-dispose crash when History is opened multiple times.
                  builder: (_) => HistoryScreen(vm: vm),
                ),
              ),
            ),
            // Clear button — only active when there are messages
            IconButton(
              icon:    const Icon(Icons.delete_outline_rounded, color: _textSecondary),
              tooltip: 'Clear Chat',
              onPressed: vm.hasMessages ? () => _showClearDialog(vm) : null,
            ),
            const SizedBox(width: 4),
          ],
        ),

        // ── Body ─────────────────────────────────────────────
        body: Column(
          children: [
            // Message list or empty state
            Expanded(
              child: vm.hasMessages
                  ? ListView.builder(
                      controller: _scrollController,
                      padding:    const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20,
                      ),
                      itemCount:   vm.messages.length,
                      itemBuilder: (_, index) =>
                          _ChatBubble(message: vm.messages[index]),
                    )
                  : const _EmptyState(),
            ),

            // Error banner — only shown when an error occurred
            if (vm.errorMessage != null)
              _ErrorBanner(message: vm.errorMessage!),

            // Text input + send button at the bottom
            _InputBar(
              controller: _inputController,
              isLoading:  vm.isLoading,
              onSend:     () => _handleSend(vm),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _AppBarTitle ──────────────────────────────────────────────
// The logo + app name + connection status dot shown in the app bar.
// Extracted to keep the main build method clean.
class _AppBarTitle extends StatelessWidget {
  final bool isConnected;
  const _AppBarTitle({required this.isConnected});

  static const Color _accentColor   = Color(0xFF00D4AA);
  static const Color _textPrimary   = Color(0xFFE6EDF3);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo circle
        Container(
          width:  36,
          height: 36,
          decoration: BoxDecoration(
            color:  _accentColor.withValues(alpha: 0.15),
            shape:  BoxShape.circle,
            border: Border.all(color: _accentColor, width: 1.5),
          ),
          child: const Icon(Icons.school_rounded, size: 20, color: _accentColor),
        ),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'StudyBuddy',
              style: TextStyle(
                color:      _textPrimary,
                fontSize:   16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
            // Connection status row with colored dot
            Row(
              children: [
                Container(
                  width:  7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isConnected ? 'Ollama Connected' : 'Ollama Offline',
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

// ── _ChatBubble ───────────────────────────────────────────────
// One message bubble — aligns right for user, left for bot.
// Shows a typing indicator if the message is still loading.
class _ChatBubble extends StatelessWidget {
  final MessageModel message;
  const _ChatBubble({required this.message});

  static const Color _userBubble  = Color(0xFF1F6FEB);
  static const Color _botBubble   = Color(0xFF21262D);
 
  static const Color _textPrimary = Color(0xFFE6EDF3);

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
          // Bot avatar (left side)
          if (!isUser) ...[
            _Avatar(isUser: false),
            const SizedBox(width: 8),
          ],

          // The actual bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? _userBubble : _botBubble,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color:     Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset:    const Offset(0, 2),
                  ),
                ],
              ),
              // Show typing dots if still loading, otherwise show text
              child: message.isLoading
                  ? const _TypingIndicator()
                  : Text(
                      message.content,
                      style: const TextStyle(
                        color:    _textPrimary,
                        fontSize: 14.5,
                        height:   1.5,
                      ),
                    ),
            ),
          ),

          // User avatar (right side)
          if (isUser) ...[
            const SizedBox(width: 8),
            _Avatar(isUser: true),
          ],
        ],
      ),
    );
  }
}

// ── _Avatar ───────────────────────────────────────────────────
// Small circular avatar next to each bubble.
// Shows a person icon for user, school icon for bot.
class _Avatar extends StatelessWidget {
  final bool isUser;
  const _Avatar({required this.isUser});

  static const Color _accentColor = Color(0xFF00D4AA);
  static const Color _userBubble  = Color(0xFF1F6FEB);
  static const Color _textPrimary = Color(0xFFE6EDF3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? _userBubble.withValues(alpha: 0.3)
            : _accentColor.withValues(alpha: 0.15),
        shape:  BoxShape.circle,
        border: Border.all(
          color: isUser ? _userBubble : _accentColor,
          width: 1,
        ),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.school_rounded,
        size:  16,
        color: isUser ? _textPrimary : _accentColor,
      ),
    );
  }
}

// ── _TypingIndicator ──────────────────────────────────────────
// Three animated dots shown while StudyBuddy is "typing".
// Each dot fades in and out with a slight delay between them.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {

  late List<AnimationController> _controllers;
  late List<Animation<double>>   _animations;

  @override
  void initState() {
    super.initState();

    // Create 3 animation controllers — one per dot
    _controllers = List.generate(3, (i) =>
      AnimationController(
        vsync:    this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    // Each controller fades its dot between 30% and 100% opacity
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0.3, end: 1).animate(c))
        .toList();

    // Start each dot with a small delay so they pulse one after another
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
          opacity: _animations[i],
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width:  8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00D4AA),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

// ── _EmptyState ───────────────────────────────────────────────
// Shown in the center of the screen before any messages are sent.
// Displays a greeting and tappable suggestion chips.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color _accentColor   = Color(0xFF00D4AA);
  static const Color _textPrimary   = Color(0xFFE6EDF3);
  static const Color _textSecondary = Color(0xFF8B949E);

  // These suggestions appear as tappable chips at the bottom
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

          // Large chat icon
          Container(
            width:  80,
            height: 80,
            decoration: BoxDecoration(
              color:  _accentColor.withValues(alpha: 0.1),
              shape:  BoxShape.circle,
              border: Border.all(
                color: _accentColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size:  38,
              color: _accentColor,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Hello, I\'m StudyBuddy! 👋',
            style: TextStyle(
              color:      _textPrimary,
              fontSize:   20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Ask me anything about your studies!\nI\'m here to help you learn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.6),
          ),

          const SizedBox(height: 32),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking:',
              style: TextStyle(
                color:      _textSecondary,
                fontSize:   13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Render one chip per suggestion
          ..._suggestions.map((text) => _SuggestionChip(text: text)),
        ],
      ),
    );
  }
}

// ── _SuggestionChip ───────────────────────────────────────────
// A tappable row that pre-fills and sends a suggested question.
class _SuggestionChip extends StatelessWidget {
  final String text;
  const _SuggestionChip({required this.text});

  static const Color _cardColor   = Color(0xFF21262D);
  static const Color _accentColor = Color(0xFF00D4AA);
  static const Color _textPrimary = Color(0xFFE6EDF3);
  static const Color _borderColor = Color(0xFF30363D);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Strip emoji characters before sending the message
        final clean = text.replaceAll(RegExp(r'[^\w\s?,!.]'), '').trim();
        ChangeNotifierProvider.of<ChatViewModel>(context).sendMessage(clean);
      },
      child: Container(
        width:   double.infinity,
        margin:  const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color:        _cardColor,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: _textPrimary, fontSize: 14),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size:  13,
              color: _accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _ErrorBanner ─────────────────────────────────────────────
// A red banner shown above the input bar when an error occurs
// (e.g. Ollama is offline or the request timed out).
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _InputBar ─────────────────────────────────────────────────
// The text field + send button pinned to the bottom of the screen.
// The send button turns into a loading spinner while waiting.
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool                  isLoading;
  final VoidCallback          onSend;

  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  static const Color _surfaceColor  = Color(0xFF161B22);
  static const Color _cardColor     = Color(0xFF21262D);
  static const Color _accentColor   = Color(0xFF00D4AA);
  static const Color _textPrimary   = Color(0xFFE6EDF3);
  static const Color _textSecondary = Color(0xFF8B949E);
  static const Color _borderColor   = Color(0xFF30363D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color:  _surfaceColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // ── Text Input ─────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:        _cardColor,
                borderRadius: BorderRadius.circular(26),
                border:       Border.all(color: _borderColor),
              ),
              child: TextField(
                controller:          controller,
                style:               const TextStyle(color: _textPrimary, fontSize: 14.5),
                maxLines:            4,
                minLines:            1,
                textCapitalization:  TextCapitalization.sentences,
                onSubmitted:         (_) => onSend(), // send on keyboard enter
                decoration: const InputDecoration(
                  hintText:       'Ask me a study question...',
                  hintStyle:      TextStyle(color: _textSecondary, fontSize: 14.5),
                  border:         InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Send Button ────────────────────────────────────
          // Animates between active (teal glow) and disabled (faded) states
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  48,
              height: 48,
              decoration: BoxDecoration(
                color: isLoading
                    ? _accentColor.withValues(alpha: 0.4)
                    : _accentColor,
                shape: BoxShape.circle,
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color:     _accentColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset:    const Offset(0, 4),
                        ),
                      ],
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}