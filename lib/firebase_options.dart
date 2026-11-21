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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAkC2yV770RPoTffKfFyDzsQxJCRW941Ew',
    appId: '1:235212183893:web:16454d4f3a3343ec2777dc',
    messagingSenderId: '235212183893',
    projectId: 'kpj-gudang-2026',
    authDomain: 'kpj-gudang-2026.firebaseapp.com',
    storageBucket: 'kpj-gudang-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBanbZit4zy_TnmQYP8X2NQfpAy2iS6zaY',
    appId: '1:235212183893:android:27cb1134e35b0c132777dc',
    messagingSenderId: '235212183893',
    projectId: 'kpj-gudang-2026',
    storageBucket: 'kpj-gudang-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkAT1U4lEeE_RmyQC0Eic2djvc_bvhOJY',
    appId: '1:235212183893:ios:8e00dab2696cd3e92777dc',
    messagingSenderId: '235212183893',
    projectId: 'kpj-gudang-2026',
    storageBucket: 'kpj-gudang-2026.firebasestorage.app',
    iosBundleId: 'com.example.kpj',
  );
}
