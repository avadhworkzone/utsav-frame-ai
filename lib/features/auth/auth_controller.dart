import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/routes/app_routes.dart';
import '../../core/widgets/toast.dart';

class AuthController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();

  final isBusy = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    // Avoid disposing these controllers here.
    // During rapid route transitions (e.g., /app -> /login), widgets may rebuild
    // while GetX is tearing down controllers, causing "used after being disposed".
    // For this UI prototype, keeping them alive is fine; for production,
    // move controllers to the widget layer or coordinate teardown more strictly.
    super.onClose();
  }

  Future<void> login() async {
    isBusy.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isBusy.value = false;
    Toast.success('Welcome', 'You are logged in (demo).');
    Get.offAllNamed(AppRoutes.shell);
  }

  Future<void> signInWithGoogle() async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          isBusy.value = false;
          return;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      Toast.success('Welcome', 'Signed in with Google.');
      Get.offAllNamed(AppRoutes.shell);
    } catch (e) {
      Toast.error('Google sign-in failed', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> signup() async {
    isBusy.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    isBusy.value = false;
    Toast.success('Account created', 'You can start creating templates.');
    Get.offAllNamed(AppRoutes.shell);
  }

  Future<void> sendResetLink() async {
    isBusy.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    isBusy.value = false;
    Toast.success('Email sent', 'Password reset link sent (demo).');
    Get.back();
  }

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
