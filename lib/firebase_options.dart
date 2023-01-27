// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDtKT5Dd-NOko6DCWgDFl6NqfJPCE8_4XQ',
    appId: '1:791604879416:web:1cb336fcfa0e4ed5e086cd',
    messagingSenderId: '791604879416',
    projectId: 'enreda-d3b41',
    authDomain: 'enreda-d3b41.firebaseapp.com',
    databaseURL: 'https://enreda-d3b41.firebaseio.com',
    storageBucket: 'enreda-d3b41.appspot.com',
    measurementId: 'G-JZ5WH4YN96',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlgBp23w5QCr2kQ40u2xcf9Vs-gocrZGI',
    appId: '1:791604879416:android:319aa93a85291a6ee086cd',
    messagingSenderId: '791604879416',
    projectId: 'enreda-d3b41',
    databaseURL: 'https://enreda-d3b41.firebaseio.com',
    storageBucket: 'enreda-d3b41.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhgFnypW2P9ce7KNVrrVkMknRuvniuD3o',
    appId: '1:791604879416:ios:ec7c5c6bcef597cde086cd',
    messagingSenderId: '791604879416',
    projectId: 'enreda-d3b41',
    databaseURL: 'https://enreda-d3b41.firebaseio.com',
    storageBucket: 'enreda-d3b41.appspot.com',
    androidClientId: '791604879416-4kgdq267i6qdutk56llo04qaf6igvq96.apps.googleusercontent.com',
    iosClientId: '791604879416-g9tit6u4qfcjl258daauc68dik9gdldj.apps.googleusercontent.com',
    iosBundleId: 'org.sic4change.enredaApp',
  );
}
