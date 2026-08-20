import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/auth/login_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // login
  Future<LoginResponse> login(LoginRequest requestbody) async {
    try {
      final response = await _apiClient.post(
        Endpoints.login,
        data: requestbody.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginOtpResponse> verifyLoginOtp(LoginOtpRequest request) async {
    final response = await _apiClient.post(
      Endpoints.verifyLoginOtp,
      data: request.toJson(),
    );

    return LoginOtpResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
