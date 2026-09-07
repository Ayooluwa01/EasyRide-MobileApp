import 'package:easy_ride/app/services/user_service.dart';
import 'package:easy_ride/features/auth/models/user/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    try {
      final userService = ref.read(userServiceProvider);

      return await userService.getMe();
    } catch (e, stackTrace) {
      throw AsyncError(e, stackTrace);
    }
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final userService = ref.read(userServiceProvider);
      return await userService.getMe();
    });
  }

  void updateOnlineStatus(bool isOnline) {
    final user = state.valueOrNull;

    if (user?.driverProfile == null) return;
    user!.driverProfile!.isOnline = isOnline;
    state = AsyncData(user);
  }

  void clearUser() {
    state = const AsyncData(null);
  }
}

final currentUserProvider = AsyncNotifierProvider<UserController, User?>(
  UserController.new,
);
