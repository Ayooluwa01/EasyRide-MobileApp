import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/features/auth/models/auth/login_model.dart';
import 'package:easy_ride/features/auth/models/auth/otp_model.dart';
import 'package:easy_ride/features/auth/models/auth/signup_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref ref;
  AuthService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  // =========================
  // LOGIN
  // =========================
  Future<LoginResponse> login(LoginRequest requestBody) async {
    try {
      final response = await _apiClient.post(
        Endpoints.login,
        data: requestBody.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // VERIFY LOGIN OTP
  // =========================
  Future<LoginOtpResponse> verifyLoginOtp(VerifyLoginOtpRequest request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.verifyLoginOtp,
        data: request.toJson(),
      );
      return LoginOtpResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SIGNUP
  // =========================
  Future<SignupResponse> signup(SignupRequest request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.signup,
        data: request.toJson(),
      );
      return SignupResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // VERIFY SIGNUP OTP
  // =========================
  Future<SignupOtpResponse> verifySignupOtp(
    VerifySignupOtpRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        Endpoints.verifySignupOtp,
        data: request.toJson(),
      );
      return SignupOtpResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // RESEND OTP
  // =========================
  Future<OtpResponseModel> resendOtp(OtpRequestModel request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.resendOtp,
        data: request.toJson(),
      );
      return OtpResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
