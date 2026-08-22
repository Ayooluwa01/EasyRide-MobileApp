import 'dart:async';
import 'package:easy_ride/app/shared/app-activity-provider.dart';
import 'package:easy_ride/features/auth/models/auth/login_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_ride/app/services/auth_service.dart';
import 'package:easy_ride/features/auth/models/auth/signup_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthController extends AsyncNotifier<LoginOtpResponse?> {
  static const String _accessTokenKey = 'access-token';
  static const String _refreshTokenKey = 'refresh-token';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AppActivityNotifier get _preloader => ref.read(appActivityProvider.notifier);

  @override
  FutureOr<LoginOtpResponse?> build() {
    return null;
  }

  Future<LoginResponse?> login(LoginRequest request) async {
    _preloader.startLoading();
    state = const AsyncValue.loading();
    try {
      LoginResponse? response;
      state = await AsyncValue.guard(() async {
        final authService = ref.read(authServiceProvider);
        response = await authService.login(request);
      });

      if (state.hasError) {
        throw state.error!;
      }

      return response;
    } finally {
      _preloader.stopLoading();
    }
  }

  Future<LoginOtpResponse> verifyLogin(VerifyLoginOtpRequest request) async {
    _preloader.startLoading();
    state = const AsyncValue.loading();

    late LoginOtpResponse response;
    try {
      state = await AsyncValue.guard(() async {
        final authService = ref.read(authServiceProvider);
        response = await authService.verifyLoginOtp(request);

        // Uncomment when ready to write tokens
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
    } catch (e, stackTrace) {
      rethrow;
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
    } catch (e, stackTrace) {
      print(e);
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

        // Uncomment when ready to write tokens
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
    } catch (e, stackTrace) {
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
