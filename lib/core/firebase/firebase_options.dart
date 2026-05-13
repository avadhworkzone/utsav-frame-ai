import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions are not configured for this platform yet. '
          'Run `flutterfire configure` to generate options for Android/iOS/Desktop.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError('FirebaseOptions not supported for fuchsia.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD8MQBDqwuMUZWEBcu9AHLvCMFAz1gP91E',
    appId: '1:650477399820:web:fddbed7c62b9568c32e329',
    messagingSenderId: '650477399820',
    projectId: 'utsavframeai',
    authDomain: 'utsavframeai.firebaseapp.com',
    // This Firebase project uses the newer Firebase Storage bucket naming.
    storageBucket: 'utsavframeai.firebasestorage.app',
    measurementId: 'G-24KP61714P',
  );
}
