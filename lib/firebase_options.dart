import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAvA9ZYZTzvkEnBCNfvXiB1xCUorT4VhA0',
    appId: '1:521966517625:android:1b17286b79e13600f403a8',
    messagingSenderId: '521966517625',
    projectId: 'lab1-flutter-app',
    storageBucket: 'lab1-flutter-app.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAt8pN8_dj9s7DJj02J26TSnjbP26i8IiM',
    appId: '1:521966517625:web:44f0338d86e78131f403a8',
    messagingSenderId: '521966517625',
    projectId: 'lab1-flutter-app',
    authDomain: 'lab1-flutter-app.firebaseapp.com',
    storageBucket: 'lab1-flutter-app.firebasestorage.app',
    measurementId: 'G-2NCVKNS0M6',
  );
}
