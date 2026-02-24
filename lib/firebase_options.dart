// Firebase configuration generated manually from google-services.json.
// If you add more platforms later, regenerate with `flutterfire configure`.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTper4j2VSsvfJYA-gKWEV3VGg1C_G5Vo',
    appId: '1:783439106548:android:daa6d14c6461fa22ff69a1',
    messagingSenderId: '783439106548',
    projectId: 'habits-d9aeb',
    storageBucket: 'habits-d9aeb.firebasestorage.app',
  );
}
