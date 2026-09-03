import 'dart:async';

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/ride_history_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideHistory extends AsyncNotifier<List<RideHistoryModel>> {
  @override
  FutureOr<List<RideHistoryModel>> build() {
    return [];
  }

  // Fetch user ride/trip history
  Future<void> getUserTrips() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(Endpoints.rides);
      final parsed = RideHistoryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return parsed.data.rides;
    });
  }
}

final rideHistoryProvider =
    AsyncNotifierProvider<RideHistory, List<RideHistoryModel>>(RideHistory.new);
