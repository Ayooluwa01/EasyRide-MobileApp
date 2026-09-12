import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startRideProvider = Provider<StartRide>((ref) {
  return StartRide(ref);
});

class StartRide {
  final Ref ref;
  StartRide(this.ref);
  ApiClient get _apiClient => ref.read(apiClientProvider);
  Future<void> startRide(String rideId) async {
    try {
      final response = await _apiClient.post('/rides/$rideId/start');
      developer.log('START RIDE RESPONSE: ${response.data}');
      final data = response.data;
      developer.log('START RIDE DATA: $data');
      final status = data['status'];
      developer.log('RIDE STATUS: $status');
    } catch (e, stackTrace) {
      developer.log('START RIDE ERROR: $e', stackTrace: stackTrace);
    }
  }
}
