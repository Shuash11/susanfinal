// lib/firebase_options.dart
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    } else if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for platforms other than Android, iOS, or Web.',
    );
  }

  static const String _apiKey = 'AIzaSyANAs-c8RfjiKIu95KbMX_UUzjYu08lxsM';
  static const String _appId = '1:551103993995:android:115d3b584c5a1a31c31c8e';
  static const String _messagingSenderId = '551103993995';
  static const String _projectId = 'studybuddy-59119';
  static const String _authDomain = 'studybuddy-59119.firebaseapp.com';
  static const String _storageBucket = 'studybuddy-59119.firebasestorage.app';

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: _authDomain,
    storageBucket: _storageBucket,
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );
}
