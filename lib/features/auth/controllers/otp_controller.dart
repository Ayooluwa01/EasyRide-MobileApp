import 'dart:async';

import 'package:easy_ride/app/services/auth_service.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/features/auth/models/auth/otp_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpController extends AsyncNotifier<void> {
  AppActivityNotifier get _preloader => ref.read(appActivityProvider.notifier);

  @override
  FutureOr<void> build() {}

  Future<OtpResponseModel> resendOtp(OtpRequestModel request) async {
    _preloader.startLoading();
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);

      final response = await authService.resendOtp(request);
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

final otpControllerProvider = AsyncNotifierProvider<OtpController, void>(
  OtpController.new,
);
