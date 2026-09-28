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
      final body = response.data['data'] as Map<String, dynamic>;

      final userJson = body['user'] as Map<String, dynamic>;

      developer.log('Contacts: ${userJson['contacts']}', name: 'UserService');

      return User.fromJson({...userJson, 'nextStep': body['nextStep']});
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
