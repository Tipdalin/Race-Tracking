import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCknay0NJpAkO6EC9K1vFZHtdPN032Z8f8',
    appId: '1:250867623840:web:633075cc1a52c3f520e6c5',
    messagingSenderId: '250867623840',
    projectId: 'race-tracking-app-883cd',
    authDomain: 'race-tracking-app-883cd.firebaseapp.com',
    storageBucket: 'race-tracking-app-883cd.firebasestorage.app',
    measurementId: 'G-C7DNNW3BCM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQBPmWQpZ10XTB4jH1Fbv27TNhliRe5LQ',
    appId: '1:250867623840:android:9f9469ecf7439aa120e6c5',
    messagingSenderId: '250867623840',
    projectId: 'race-tracking-app-883cd',
    storageBucket: 'race-tracking-app-883cd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCK2si2MpAn48Xu986dETnsNGGj_MY4kls',
    appId: '1:250867623840:ios:84988a7fa361b0d020e6c5',
    messagingSenderId: '250867623840',
    projectId: 'race-tracking-app-883cd',
    storageBucket: 'race-tracking-app-883cd.firebasestorage.app',
    iosBundleId: 'com.example.raceTracking',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCK2si2MpAn48Xu986dETnsNGGj_MY4kls',
    appId: '1:250867623840:ios:84988a7fa361b0d020e6c5',
    messagingSenderId: '250867623840',
    projectId: 'race-tracking-app-883cd',
    storageBucket: 'race-tracking-app-883cd.firebasestorage.app',
    iosBundleId: 'com.example.raceTracking',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCknay0NJpAkO6EC9K1vFZHtdPN032Z8f8',
    appId: '1:250867623840:web:6e4abdac45acdfe020e6c5',
    messagingSenderId: '250867623840',
    projectId: 'race-tracking-app-883cd',
    authDomain: 'race-tracking-app-883cd.firebaseapp.com',
    storageBucket: 'race-tracking-app-883cd.firebasestorage.app',
    measurementId: 'G-E7KKJM1Q4Z',
  );

}