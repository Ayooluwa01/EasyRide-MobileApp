import 'package:easy_ride/features/auth/models/user/user_model.dart';

class LoginRequest {
  final String phone;
  final String email;

  LoginRequest({required this.email, required this.phone});

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'email': email};
  }
}

class LoginResponse {
  final bool success;
  final int statusCode;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class LoginData {
  final bool success;
  final String otpSent;
  final String message;
  final int expiresInSeconds;

  LoginData({
    required this.success,
    required this.otpSent,
    required this.message,
    required this.expiresInSeconds,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      success: json['success'] as bool? ?? false,
      otpSent: json['otpSent'] as String? ?? '',
      message: json['message'] as String? ?? '',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 0,
    );
  }
}

class VerifyLoginOtpRequest {
  final String phone;
  final String code;

  VerifyLoginOtpRequest({required this.phone, required this.code});
  Map<String, dynamic> toJson() {
    return {'phone': phone, 'code': code};
  }
}

class LoginOtpResponse {
  final bool success;
  final LoginOtpData data;
  final String? message;

  LoginOtpResponse({required this.success, required this.data, this.message});

  factory LoginOtpResponse.fromJson(Map<String, dynamic> json) {
    return LoginOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',

      data: LoginOtpData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class LoginOtpData {
  final User user;
  final String accessToken;
  final String refreshToken;

  LoginOtpData({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginOtpData.fromJson(Map<String, dynamic> json) {
    return LoginOtpData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
