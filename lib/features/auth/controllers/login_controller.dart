import 'dart:async';

import 'package:easy_ride/app/services/auth_service.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/features/auth/models/auth/login_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends AsyncNotifier<LoginOtpResponse?> {
  AppActivityNotifier get _preloader => ref.read(appActivityProvider.notifier);

  @override
  FutureOr<LoginOtpResponse?> build() {
    return null;
  }

  // =========================
  // LOGIN
  // =========================

  Future<LoginResponse> login(LoginRequest request) async {
    _preloader.startLoading();

    try {
      final authService = ref.read(authServiceProvider);

      final response = await authService.login(request);

      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    } finally {
      _preloader.stopLoading();
    }
  }

  // =========================
  // VERIFY LOGIN OTP
  // =========================

  Future<LoginOtpResponse> verifyLogin(VerifyLoginOtpRequest request) async {
    _preloader.startLoading();

    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.verifyLoginOtp(request);
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

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, LoginOtpResponse?>(
      LoginController.new,
    );
