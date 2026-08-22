class SignupRequest {
  final String phone;
  final String role;
  final String fullname;
  final String email;

  SignupRequest({
    required this.phone,
    required this.role,
    required this.fullname,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'role': role, 'fullname': fullname, 'email': email};
  }
}

class SignupResponse {
  final bool success;
  final String message;

  SignupResponse({required this.success, required this.message});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

class VerifySignupOtpRequest {
  final String phone;
  final String code;

  VerifySignupOtpRequest({required this.phone, required this.code});

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'code': code};
  }
}

class SignupOtpResponse {
  final bool success;
  final String message;
  final SignupOtpData data;

  SignupOtpResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SignupOtpResponse.fromJson(Map<String, dynamic> json) {
    return SignupOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: SignupOtpData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SignupOtpData {
  final String accessToken;
  final String refreshToken;

  SignupOtpData({required this.accessToken, required this.refreshToken});

  factory SignupOtpData.fromJson(Map<String, dynamic> json) {
    return SignupOtpData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
