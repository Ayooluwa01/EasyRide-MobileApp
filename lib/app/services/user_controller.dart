import 'dart:async';

import 'package:easy_ride/app/services/user_service.dart';
import 'package:easy_ride/features/auth/models/user/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return null;
  }

  Future<User?> getCurrentUser() async {
    try {
      final userService = ref.read(userServiceProvider);

      final user = await userService.getMe();

      state = AsyncValue.data(user);

      return user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
    return null;
  }
}

final currentUserProvider = AsyncNotifierProvider<UserController, User?>(
  UserController.new,
);
