import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await UserRepository.initializeFirebase();
  } catch (e) {
    // Firebase init error
    print('Init error: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const NoInternetWrapper());
}

class NoInternetWrapper extends StatefulWidget {
  const NoInternetWrapper({super.key});

  @override
  State<NoInternetWrapper> createState() => _NoInternetWrapperState();
}

class _NoInternetWrapperState extends State<NoInternetWrapper> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      if (mounted) {
        _showNoInternetDialog();
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Color(0xFF00D4AA)),
            SizedBox(width: 8),
            Text('No Internet', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Please check your internet connection and try again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              checkConnection();
            },
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF00D4AA)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const StudyBuddyApp();
  }
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4AA),
          secondary: Color(0xFF1F6FEB),
          surface: Color(0xFF161B22),
        ),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
