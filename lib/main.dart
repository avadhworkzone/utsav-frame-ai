import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on PlatformException catch (e) {
    debugPrint('Firebase init failed (PlatformException): ${e.code} ${e.message}');
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  runApp(const App());
}
