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
    apiKey: 'AIzaSyBeNfQ7scMBx8KD44RJNxR5LzigxH2B9cU',
    appId: '1:503721719130:web:08b52ce495a0b40fb26f63',
    messagingSenderId: '503721719130',
    projectId: 'true-application3',
    authDomain: 'true-application3.firebaseapp.com',
    storageBucket: 'true-application3.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC75HXZaSkMwbG2z0n_Zbb3l9AwJ_ZOAn4',
    appId: '1:503721719130:android:a7bbddbcbf2f9672b26f63',
    messagingSenderId: '503721719130',
    projectId: 'true-application3',
    storageBucket: 'true-application3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCP7ScGsXSNdR82xgBJQkE9nMckZNDgdT4',
    appId: '1:503721719130:ios:cd5a44bd2a11b944b26f63',
    messagingSenderId: '503721719130',
    projectId: 'true-application3',
    storageBucket: 'true-application3.firebasestorage.app',
    iosBundleId: 'com.example.trueApplication3',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCP7ScGsXSNdR82xgBJQkE9nMckZNDgdT4',
    appId: '1:503721719130:ios:cd5a44bd2a11b944b26f63',
    messagingSenderId: '503721719130',
    projectId: 'true-application3',
    storageBucket: 'true-application3.firebasestorage.app',
    iosBundleId: 'com.example.trueApplication3',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBeNfQ7scMBx8KD44RJNxR5LzigxH2B9cU',
    appId: '1:503721719130:web:03def73ec61b9c7db26f63',
    messagingSenderId: '503721719130',
    projectId: 'true-application3',
    authDomain: 'true-application3.firebaseapp.com',
    storageBucket: 'true-application3.firebasestorage.app',
  );
}
