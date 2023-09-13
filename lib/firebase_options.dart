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
        return macos;
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
    apiKey: 'AIzaSyByNGxiqN_llv3iN5SZffe9Y-WBtkgGtRQ',
    appId: '1:1070862182524:web:7feca6b3f0736afd5481f9',
    messagingSenderId: '1070862182524',
    projectId: 'taxi-fa3d3',
    authDomain: 'taxi-fa3d3.firebaseapp.com',
    databaseURL: 'https://taxi-fa3d3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'taxi-fa3d3.appspot.com',
    measurementId: 'G-WDH8B948CM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2CHHUmIGRJwt-sKnfwVVGKxbvh5b_yb0',
    appId: '1:1070862182524:android:34a2579e8b753f355481f9',
    messagingSenderId: '1070862182524',
    projectId: 'taxi-fa3d3',
    databaseURL: 'https://taxi-fa3d3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'taxi-fa3d3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANuAx9odJxI7MJQMmG09HseTz6wzcJK9o',
    appId: '1:1070862182524:ios:e480ffc8834844f85481f9',
    messagingSenderId: '1070862182524',
    projectId: 'taxi-fa3d3',
    databaseURL: 'https://taxi-fa3d3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'taxi-fa3d3.appspot.com',
    iosBundleId: 'com.example.flutterAppTexting',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANuAx9odJxI7MJQMmG09HseTz6wzcJK9o',
    appId: '1:1070862182524:ios:cad206e8be009cc75481f9',
    messagingSenderId: '1070862182524',
    projectId: 'taxi-fa3d3',
    databaseURL: 'https://taxi-fa3d3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'taxi-fa3d3.appspot.com',
    iosBundleId: 'com.example.flutterAppTexting.RunnerTests',
  );
}
