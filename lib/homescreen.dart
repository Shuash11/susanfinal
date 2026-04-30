// ============================================================
// FILE: homescreen.dart
// DESC: Main scaffold — routing logic and dialogs only.
// ============================================================

import 'package:flutter/material.dart';
import 'chatmodel.dart';
import 'spash_screen.dart';
import 'history.dart';
import 'chat_widgets.dart';
import 'chat_drawer.dart';
import 'dashboard_view.dart';
import 'chat_view.dart';
import 'profile_screen.dart';
import 'user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Resolved once from the singleton repository
  String get _username =>
      UserRepository().currentUsername ?? 'Student';

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll ───────────────────────────────────────────────────
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Send ─────────────────────────────────────────────────────
  void _handleSend(ChatViewModel vm) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    vm.sendMessage(text);
    _scrollToBottom();
  }

  // ── Profile ──────────────────────────────────────────────────
  void _openProfile(ChatViewModel vm) {
    // Close the drawer first, then push after the frame settles
    Navigator.pop(context);
    Future.microtask(() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(vm: vm, username: _username),
        ),
      );
    });
  }

  // ── Dialogs ──────────────────────────────────────────────────
  void _showNewChatDialog(ChatViewModel vm) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: kAccent, width: 1.5),
              ),
              child: const Icon(Icons.add_rounded, size: 20, color: kAccent),
            ),
            const SizedBox(width: 12),
            const Text('New Chat',
                style: TextStyle(
                  color: kTextPri,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Give your chat a name so you can find it later.',
              style: TextStyle(color: kTextSec, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: kTextPri, fontSize: 14.5),
              onSubmitted: (_) => _handleNewChatSubmit(ctx, vm, nameCtrl),
              decoration: InputDecoration(
                hintText: 'e.g. Algebra homework',
                hintStyle: const TextStyle(color: kTextSec, fontSize: 14),
                prefixIcon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: kTextSec, size: 18),
                filled: true,
                fillColor: kBg,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kAccent, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: kTextSec)),
          ),
          ElevatedButton(
            onPressed: () => _createChat(ctx, vm, nameCtrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Create',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleNewChatSubmit(BuildContext ctx, ChatViewModel vm,
      TextEditingController ctrl) {
    _createChat(ctx, vm, ctrl);
  }

  void _createChat(BuildContext ctx, ChatViewModel vm,
      TextEditingController ctrl) {
    final name = ctrl.text.trim().isEmpty ? 'New Chat' : ctrl.text.trim();
    vm.createSession(name);
    Navigator.pop(ctx);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _confirmDeleteSession(ChatViewModel vm, ChatSession session) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Chat',
            style: TextStyle(color: kTextPri, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${session.name}"? This cannot be undone.',
          style: const TextStyle(color: kTextSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: kTextSec)),
          ),
          TextButton(
            onPressed: () {
              vm.deleteSession(session.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(ChatViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Messages',
            style: TextStyle(color: kTextPri, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to clear all messages in this chat?',
          style: TextStyle(color: kTextSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: kTextSec)),
          ),
          TextButton(
            onPressed: () {
              vm.clearChat();
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vm = ChangeNotifierProvider.of<ChatViewModel>(context);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: kBg,

        drawer: ChatDrawer(
          vm: vm,
          username: _username,
          onNewChat: () {
            Navigator.pop(context);
            _showNewChatDialog(vm);
          },
          onProfile: () => _openProfile(vm),
          onSelectSession: (s) {
            vm.openSession(s.id);
            Navigator.pop(context);
          },
          onDeleteSession: (s) => _confirmDeleteSession(vm, s),
        ),

        appBar: AppBar(
          backgroundColor: kSurface,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: kBorder),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: kTextPri),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Recent Chats',
          ),
          title: vm.hasActiveSession
              ? ActiveChatTitle(session: vm.activeSession!)
              : AppBarTitle(isConnected: vm.isOllamaConnected),
          actions: [
            if (vm.hasActiveSession) ...[
              IconButton(
                icon: const Icon(Icons.history_rounded, color: kTextSec),
                tooltip: 'Message History',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HistoryScreen(vm: vm)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: kTextSec),
                tooltip: 'Clear Messages',
                onPressed:
                    vm.hasMessages ? () => _showClearDialog(vm) : null,
              ),
            ],
            const SizedBox(width: 4),
          ],
        ),

        body: vm.hasActiveSession
            ? ChatView(
                vm: vm,
                scrollController: _scrollController,
                inputController: _inputController,
                onSend: () => _handleSend(vm),
              )
            : DashboardView(
                vm: vm,
                onNewChat: () => _showNewChatDialog(vm),
                onSelectSession: (s) => vm.openSession(s.id),
                onDeleteSession: (s) => _confirmDeleteSession(vm, s),
              ),
      ),
    );
  }
}