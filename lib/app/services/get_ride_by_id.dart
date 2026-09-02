// get_ride_by_id_notifier.dart

import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/models/get_ride_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetRideByIdNotifier extends AsyncNotifier<GetRideByIdModel?> {
  @override
  Future<GetRideByIdModel?> build() async {
    return null;
  }

  Future<void> fetchRide(String rideId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/rides/$rideId');
      developer.log(
        'Response from /rides/$rideId: $response',
        name: 'GetRideByIdNotifier',
      );
      final parsed = GetRideByIdResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      developer.log(
        'Fetched ride: ${parsed.data}',
        name: 'GetRideByIdNotifier',
      );
      return parsed.data;
    });
  }
}

final getRideByIdProvider =
    AsyncNotifierProvider<GetRideByIdNotifier, GetRideByIdModel?>(
      GetRideByIdNotifier.new,
    );
