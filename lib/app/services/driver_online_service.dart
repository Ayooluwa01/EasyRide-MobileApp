import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/services/user_controller.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverOnlineServiceProvider = Provider<DriverOnlineService>((ref) {
  return DriverOnlineService(ref);
});

class DriverOnlineService {
  final Ref ref;

  DriverOnlineService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);
  final FlutterBackgroundService _backgroundService =
      FlutterBackgroundService();
  Future<bool> toggleOnlineStatus(bool online) async {
    try {
      final response = await _apiClient.patch(
        Endpoints.onlineStatus,
        data: {'isOnline': online},
      );

      final data = response.data['data'];
      final isOnline = data['isOnline'] as bool;

      developer.log(
        'TOGGLE ONLINE RESPONSE: $data',
        name: 'DriverOnlineService',
      );

      // Update UI state
      ref.read(currentUserProvider.notifier).updateOnlineStatus(isOnline);

      // Start/stop background tracking immediately
      await syncBackgroundTracking(isOnline);

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

  Future<void> syncBackgroundTracking(bool isOnline) async {
    developer.log(
      'SYNC BACKGROUND TRACKING: isOnline=$isOnline',
      name: 'DriverOnlineService',
    );

    if (isOnline) {
      await _startBackgroundTracking();
    } else {
      await _stopBackgroundTracking();
    }
  }

  Future<void> _startBackgroundTracking() async {
    final isRunning = await _backgroundService.isRunning();
    developer.log(
      'BACKGROUND: isRunning=$isRunning',
      name: 'DriverOnlineService',
    );
    if (!isRunning) {
      developer.log(
        'BACKGROUND: Starting service',
        name: 'DriverOnlineService',
      );

      await _backgroundService.startService();
    }
  }

  Future<void> _stopBackgroundTracking() async {
    _backgroundService.invoke('stop_tracking');
  }
}
