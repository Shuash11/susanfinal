import 'package:flutter/material.dart';
import 'chatmodel.dart';
import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation ───────────────────────────────────────────────
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), _navigateToHome);
      }
    });

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted && _controller.status != AnimationStatus.completed) {
        _controller.forward();
      }
    });
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChangeNotifierProvider(
          create: (_) => ChatViewModel()..initialize(),
          child: const HomeScreen(),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Dark gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: const _SplashContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  static const Color _accent = Color(0xFF00D4AA);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: _accent, width: 2),
          ),
          child: const Icon(Icons.school_rounded, size: 52, color: _accent),
        ),

        const SizedBox(height: 28),

        // ── App Name ─────────────────────────────────────────
        const Text(
          'StudyBuddy',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Your AI-powered study companion',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 60),

        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              _accent.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext) create;
  final Widget child;

  const ChangeNotifierProvider({
    super.key,
    required this.create,
    required this.child,
  });

  static T of<T extends ChangeNotifier>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedProvider<T>>()!
        .notifier;
  }

  @override
  State<ChangeNotifierProvider<T>> createState() =>
      _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier>
    extends State<ChangeNotifierProvider<T>> {
  late T _notifier;
  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
    _notifier.addListener(_onNotifierChanged);
  }

  void _onNotifierChanged() => setState(() {});

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _InheritedProvider<T extends ChangeNotifier> extends InheritedWidget {
  final T notifier;

  const _InheritedProvider({
    required this.notifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedProvider<T> oldWidget) => true;
}
