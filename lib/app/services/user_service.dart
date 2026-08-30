import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/features/auth/models/user/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref);
});

class UserService {
  final Ref ref;

  UserService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<User> getMe() async {
    try {
      final response = await _apiClient.get(Endpoints.getMe);

      return User.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get current user',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
