// THIS FILE IS AUTO-GENERATED. Do not edit manually.
// To regenerate: run `flutterfire configure` while logged into the correct
// Firebase account that owns project drapo-7.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web platform not configured.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for ${defaultTargetPlatform.name}.',
        );
    }
  }

  // Android — from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCDqinCnTXN1FfuOQc8LC0ML5-eLxKUd4',
    appId: '1:986206394751:android:e0a1899e51c72245aba24a',
    messagingSenderId: '986206394751',
    projectId: 'drapo7',
    storageBucket: 'drapo7.firebasestorage.app',
  );

  // iOS — replace with values from GoogleService-Info.plist when available
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '986206394751',
    projectId: 'drapo7',
    storageBucket: 'drapo7.firebasestorage.app',
    iosBundleId: 'com.drapo.drapo',
  );
}
