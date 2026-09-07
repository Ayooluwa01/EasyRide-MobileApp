import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/services/user_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverOnlineServiceProvider = Provider<DriverOnlineService>((ref) {
  return DriverOnlineService(ref);
});

class DriverOnlineService {
  final Ref ref;

  DriverOnlineService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<bool> toggleOnlineStatus(bool online) async {
    try {
      final response = await _apiClient.patch(
        Endpoints.onlineStatus,
        data: {'isOnline': online},
      );

      final data = response.data['data'];
      developer.log(
        'TOGGLE ONLINE RESPONSE: $data',
        name: 'DriverOnlineService',
      );
      final isOnline = data['isOnline'] as bool;
      ref.read(currentUserProvider.notifier).updateOnlineStatus(isOnline);
      return isOnline;
    } catch (e, stackTrace) {
      developer.log(
        'TOGGLE ONLINE ERROR',
        name: 'DriverOnlineService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
