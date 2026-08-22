import 'dart:async';
import 'package:easy_ride/app/services/auth_service.dart';
import 'package:easy_ride/app/shared/app-activity-provider.dart';
import 'package:easy_ride/features/auth/models/auth/login_model.dart';
import 'package:easy_ride/features/auth/models/auth/otp_model.dart';
import 'package:easy_ride/features/auth/models/auth/signup_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends AsyncNotifier<LoginOtpResponse?> {
  static const String _accessTokenKey = 'access-token';
  static const String _refreshTokenKey = 'refresh-token';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AppActivityNotifier get _preloader => ref.read(appActivityProvider.notifier);

  @override
  FutureOr<LoginOtpResponse?> build() {
    return null;
  }

  // =========================
  // LOGIN
  // =========================
  Future<LoginResponse?> login(LoginRequest request) async {
    _preloader.startLoading();
    try {
      final authService = ref.read(authServiceProvider);
      return await authService.login(request);
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

    late LoginOtpResponse response;
    try {
      state = await AsyncValue.guard(() async {
        final authService = ref.read(authServiceProvider);
        response = await authService.verifyLoginOtp(request);

        // Uncomment when ready to store tokens:
        // await _secureStorage.write(
        //   key: _accessTokenKey,
        //   value: response.data.accessToken,
        // );
        // await _secureStorage.write(
        //   key: _refreshTokenKey,
        //   value: response.data.refreshToken,
        // );

        return response;
      });

      if (state.hasError) {
        throw state.error!;
      }

      return response;
    } finally {
      _preloader.stopLoading();
    }
  }

  // =========================
  // SIGNUP
  // =========================
  Future<SignupResponse> signup(SignupRequest request) async {
    _preloader.startLoading();
    try {
      final authService = ref.read(authServiceProvider);
      return await authService.signup(request);
    } catch (e) {
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
    late SignupOtpResponse response;

    try {
      state = await AsyncValue.guard(() async {
        final authService = ref.read(authServiceProvider);
        response = await authService.verifySignupOtp(request);

        // Uncomment when ready to store tokens:
        // await _secureStorage.write(
        //   key: _accessTokenKey,
        //   value: response.data.accessToken,
        // );
        // await _secureStorage.write(
        //   key: _refreshTokenKey,
        //   value: response.data.refreshToken,
        // );

        return LoginOtpResponse(
          success: response.success,
          message: response.message,
          data: LoginOtpData(
            accessToken: response.data.accessToken,
            refreshToken: response.data.refreshToken,
          ),
        );
      });

      if (state.hasError) {
        throw state.error!;
      }

      return response;
    } finally {
      _preloader.stopLoading();
    }
  }

  // =========================
  // RESEND OTP
  // =========================
  Future<OtpResponseModel> resendOtp(OtpRequestModel request) async {
    _preloader.startLoading();
    late OtpResponseModel response;

    try {
      final authService = ref.read(authServiceProvider);
      response = await authService.resendOtp(request);
      print(" otp-response:${response}");
      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    } finally {
      _preloader.stopLoading();
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, LoginOtpResponse?>(
      AuthController.new,
    );

// Models
