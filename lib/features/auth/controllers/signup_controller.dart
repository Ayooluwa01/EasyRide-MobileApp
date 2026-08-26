import 'dart:async';

import 'package:easy_ride/app/services/auth_service.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/features/auth/models/auth/signup_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupController extends AsyncNotifier<SignupOtpResponse?> {
  AppActivityNotifier get _preloader => ref.read(appActivityProvider.notifier);

  @override
  FutureOr<SignupOtpResponse?> build() {
    return null;
  }

  // =========================
  // SIGNUP
  // =========================

  Future<SignupResponse> signup(SignupRequest request) async {
    _preloader.startLoading();

    try {
      final authService = ref.read(authServiceProvider);

      final response = await authService.signup(request);

      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    } finally {
      _preloader.stopLoading();
    }
  }

  // =========================
  // VERIFY SIGNUP OTP
  // =========================

  Future<SignupOtpResponse> verifySignup(VerifySignupOtpRequest request) async {
    _preloader.startLoading();

    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);

      final response = await authService.verifySignupOtp(request);

      state = AsyncValue.data(response);

      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    } finally {
      _preloader.stopLoading();
    }
  }
}

final signupControllerProvider =
    AsyncNotifierProvider<SignupController, SignupOtpResponse?>(
      SignupController.new,
    );
