// Hand-written in place of the usual `flutterfire configure` output — this
// dev environment has no network access to run the FlutterFire CLI. Values
// below are copied verbatim from `android/app/google-services.json`
// (project "money-care-c454f"), which is the only platform currently
// registered in Firebase. Add web/iOS/macOS blocks here (and register those
// apps in the Firebase console) when those platforms need real sync too —
// until then `currentPlatform` throws for anything but Android, and
// `main.dart` only calls this on Android, leaving the web/desktop build on
// its existing local-only demo mode.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — this '
        'app is not registered as a Firebase Web app yet.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android so far.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkDK3QVJt7VV366_boNcGc6K212OXkOz4',
    appId: '1:689858561191:android:b5c1b435c705634bd98782',
    messagingSenderId: '689858561191',
    projectId: 'money-care-c454f',
    storageBucket: 'money-care-c454f.firebasestorage.app',
  );
}
