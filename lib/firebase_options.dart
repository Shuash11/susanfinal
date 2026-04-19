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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyANAs-c8RfjiKIu95KbMX_UUzjYu08lxsM',
    appId: '1:551103993995:android:115d3b584c5a1a31c31c8e',
    messagingSenderId: '551103993995',
    projectId: 'studybuddy-59119',
    authDomain: 'studybuddy-59119.firebaseapp.com',
    storageBucket: 'studybuddy-59119.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANAs-c8RfjiKIu95KbMX_UUzjYu08lxsM',
    appId: '1:551103993995:android:115d3b584c5a1a31c31c8e',
    messagingSenderId: '551103993995',
    projectId: 'studybuddy-59119',
    storageBucket: 'studybuddy-59119.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANAs-c8RfjiKIu95KbMX_UUzjYu08lxsM',
    appId: '1:551103993995:android:115d3b584c5a1a31c31c8e',
    messagingSenderId: '551103993995',
    projectId: 'studybuddy-59119',
    storageBucket: 'studybuddy-59119.firebasestorage.app',
  );
}
