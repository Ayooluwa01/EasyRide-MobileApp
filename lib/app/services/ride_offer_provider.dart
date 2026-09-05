import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/ride_offer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideOffersNotifier extends AsyncNotifier<List<RideOfferModel>> {
  late final ApiClient _apiClient;

  @override
  Future<List<RideOfferModel>> build() async {
    _apiClient = ref.read(apiClientProvider);

    return getActiveRideRequests();
  }

  Future<List<RideOfferModel>> getActiveRideRequests() async {
    try {
      final response = await _apiClient.get(Endpoints.rideRequets);

      developer.log(
        'AVAILABLE RIDE OFFERS: ${response.data}',
        name: 'RideOffersNotifier',
      );
      final List<dynamic> data = response.data['data'];

      return data
          .map((json) => RideOfferModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get ride offers',
        name: 'RideOffersNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> refreshOffers() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(getActiveRideRequests);
  }

  void removeOffer(String rideId) {
    final currentOffers = state.valueOrNull;
    if (currentOffers == null) return;
    state = AsyncData(
      currentOffers.where((offer) => offer.rideId != rideId).toList(),
    );
  }
}

final rideOffersProvider =
    AsyncNotifierProvider<RideOffersNotifier, List<RideOfferModel>>(
      RideOffersNotifier.new,
    );
