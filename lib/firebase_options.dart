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
    apiKey: 'AIzaSyCAVZz0e_eHLun6QSK-WRBge6UU86XPZk0',
    appId: '1:621434201995:web:5b4832cbadfb7cbafcf18e',
    messagingSenderId: '621434201995',
    projectId: 'asu-carpool-service',
    authDomain: 'asu-carpool-service.firebaseapp.com',
    databaseURL: 'https://asu-carpool-service-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'asu-carpool-service.appspot.com',
    measurementId: 'G-D05RLL85ZK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASuF7FHNvulHvJAPF6VonO1mViLWdzmss',
    appId: '1:621434201995:android:81cd794a599062e5fcf18e',
    messagingSenderId: '621434201995',
    projectId: 'asu-carpool-service',
    databaseURL: 'https://asu-carpool-service-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'asu-carpool-service.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDryAQprxFsrRBdyBndXcNfcGp-jM0uo30',
    appId: '1:621434201995:ios:6e5db1a951cfbec1fcf18e',
    messagingSenderId: '621434201995',
    projectId: 'asu-carpool-service',
    databaseURL: 'https://asu-carpool-service-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'asu-carpool-service.appspot.com',
    iosBundleId: 'com.example.driver',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDryAQprxFsrRBdyBndXcNfcGp-jM0uo30',
    appId: '1:621434201995:ios:9ecc27c3a01b05d8fcf18e',
    messagingSenderId: '621434201995',
    projectId: 'asu-carpool-service',
    databaseURL: 'https://asu-carpool-service-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'asu-carpool-service.appspot.com',
    iosBundleId: 'com.example.driver.RunnerTests',
  );
}
