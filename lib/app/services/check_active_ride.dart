import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/active_ride_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _CheckActiveRide {
  final Ref ref;

  _CheckActiveRide(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  // Check active ride for rider

  Future<RiderActiveRideModel?> checkActiveRideForRider() async {
    try {
      final response = await _apiClient.post(Endpoints.activeRide);
      developer.log('Check active ride for rider response: ${response.data}');
      final data = response.data;
      // No active ride
      if (data == null) {
        return null;
      }

      return RiderActiveRideModel.fromJson(data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      developer.log('Check active ride error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // Check active ride for driver
  Future<DriverActiveRideModel> checkActiveRideForDriver() async {
    final response = await _apiClient.post(Endpoints.activeRide);
    developer.log('Check active ride for driver response: ${response.data}');
    return DriverActiveRideModel.fromJson(response.data);
  }
}

final checkActiveRideProvider = Provider<_CheckActiveRide>((ref) {
  return _CheckActiveRide(ref);
});
