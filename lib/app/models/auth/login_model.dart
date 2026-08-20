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
  final String message;

  LoginResponse({required this.success, required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}

class LoginOtpRequest {
  final String phone;
  final String code;

  LoginOtpRequest({required this.phone, required this.code});
  Map<String, dynamic> toJson() {
    return {'phone': phone, 'code': code};
  }
}

class LoginOtpResponse {
  final bool success;
  final LoginOtpData data;

  LoginOtpResponse({required this.success, required this.data});

  factory LoginOtpResponse.fromJson(Map<String, dynamic> json) {
    return LoginOtpResponse(
      success: json['success'] as bool,
      data: LoginOtpData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class LoginOtpData {
  final String accessToken;
  final String refreshToken;

  LoginOtpData({required this.accessToken, required this.refreshToken});

  factory LoginOtpData.fromJson(Map<String, dynamic> json) {
    return LoginOtpData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
