import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/ride_offer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideOffersNotifier
    extends AutoDisposeAsyncNotifier<List<RideOfferModel>> {
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

  Future<bool> acceptOffer(String rideId, num amount) async {
    try {
      final response = await _apiClient.post(
        '/rides/$rideId/accept',
        data: {'amount': amount.toString()},
      );

      developer.log(
        'Accept ride response: ${response.data}',
        name: 'RideOffersNotifier',
      );

      removeOffer(rideId);
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to accept ride $rideId',
        name: 'RideOffersNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      await refreshOffers();
      return false;
    }
  }

  Future<bool> rejectOffer(String rideId) async {
    try {
      final response = await _apiClient.post('/rides/$rideId/reject');

      developer.log(
        'Reject ride response: ${response.data}',
        name: 'RideOffersNotifier',
      );

      removeOffer(rideId);
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to reject ride $rideId',
        name: 'RideOffersNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      await refreshOffers();
      return false;
    }
  }
}

final rideOffersProvider =
    AsyncNotifierProvider.autoDispose<RideOffersNotifier, List<RideOfferModel>>(
      RideOffersNotifier.new,
    );
