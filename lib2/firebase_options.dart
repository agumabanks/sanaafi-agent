// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyASFg-y8GmP2_pQZApKcIzC8NHnrbnU1RA',
    appId: '1:414977059359:web:baed03f4d1fc0453a1c32a',
    messagingSenderId: '414977059359',
    projectId: 'sfi-saas',
    authDomain: 'sfi-saas.firebaseapp.com',
    storageBucket: 'sfi-saas.appspot.com',
    measurementId: 'G-416CZ4663M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAdYTMpjMf8AmzjcEJ-7UQyb07S3sPN9k',
    appId: '1:414977059359:android:4dc46bf803c607f1a1c32a',
    messagingSenderId: '414977059359',
    projectId: 'sfi-saas',
    storageBucket: 'sfi-saas.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuyH2_OB6Y8oXTJTsU9F1z9gcs9sv0sp0',
    appId: '1:414977059359:ios:29695c86efdfd17ca1c32a',
    messagingSenderId: '414977059359',
    projectId: 'sfi-saas',
    storageBucket: 'sfi-saas.appspot.com',
    iosBundleId: 'com.sixamtech.cash',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyASFg-y8GmP2_pQZApKcIzC8NHnrbnU1RA',
    appId: '1:414977059359:web:0cf45f2d0fb965a7a1c32a',
    messagingSenderId: '414977059359',
    projectId: 'sfi-saas',
    authDomain: 'sfi-saas.firebaseapp.com',
    storageBucket: 'sfi-saas.appspot.com',
    measurementId: 'G-4F45T77FBY',
  );
}
