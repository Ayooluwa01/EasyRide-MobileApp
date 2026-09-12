// import 'package:easy_ride/app/services/user_service.dart';
// import 'package:easy_ride/features/auth/models/user/user_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class UserController extends AsyncNotifier<User?> {
//   @override
//   Future<User?> build() async {
//     try {
//       final userService = ref.read(userServiceProvider);

//       return await userService.getMe();
//     } catch (e, stackTrace) {
//       throw AsyncError(e, stackTrace);
//     }
//   }

//   Future<void> refreshUser() async {
//     state = const AsyncLoading();

//     state = await AsyncValue.guard(() async {
//       final userService = ref.read(userServiceProvider);
//       return await userService.getMe();
//     });
//   }

//   void updateOnlineStatus(bool isOnline) {
//     final user = state.valueOrNull;

//     if (user?.driverProfile == null) return;
//     user!.driverProfile!.isOnline = isOnline;
//     state = AsyncData(user);
//   }

//   void clearUser() {
//     state = const AsyncData(null);
//   }
// }

// final currentUserProvider = AsyncNotifierProvider<UserController, User?>(
//   UserController.new,
// );
import 'package:easy_ride/app/services/driver_online_service.dart';
import 'package:easy_ride/app/services/user_service.dart';
import 'package:easy_ride/features/auth/models/user/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.getMe();
      if (user.driverProfile != null) {
        final isOnline = user.driverProfile!.isOnline;
        // Sync background tracking with the persisted backend state.
        await ref
            .read(driverOnlineServiceProvider)
            .syncBackgroundTracking(isOnline);
      }

      return user;
    } catch (e, stackTrace) {
      throw AsyncError(e, stackTrace);
    }
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final userService = ref.read(userServiceProvider);

      final user = await userService.getMe();

      if (user.driverProfile != null) {
        final isOnline = user.driverProfile!.isOnline;

        await ref
            .read(driverOnlineServiceProvider)
            .syncBackgroundTracking(isOnline);
      }

      return user;
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
