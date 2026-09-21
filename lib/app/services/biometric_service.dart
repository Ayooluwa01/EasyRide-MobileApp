import 'package:easy_ride/app/shared/biometric_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Oops! Biometric authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(cancelButton: 'No thanks'),
        ],
      );
    } on PlatformException catch (e) {
      debugPrint('Authentication error: ${e.message}');
      return false;
    }
  }

  Future<bool> authenticateWithBarrier(
    BuildContext context, {
    required String reason,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);

    final biometrics = await getAvailableBiometrics();
    final isFace = biometrics.contains(BiometricType.face);

    if (!context.mounted) return false;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Authenticating',
      barrierColor: Colors.black54,
      useRootNavigator: true,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, __, ___) =>
          BiometricPromptDialog(isFace: isFace, reason: reason),
    );

    try {
      return await authenticate(reason: reason);
    } finally {
      navigator.pop();
    }
  }
}
