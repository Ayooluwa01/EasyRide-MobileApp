import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/ride_offer_model.dart';
import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/core/socket/socket_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideOffersNotifier
    extends AutoDisposeAsyncNotifier<List<RideOfferModel>> {
  late final ApiClient _apiClient;
  late final Websocket _socket;

  @override
  Future<List<RideOfferModel>> build() async {
    _apiClient = ref.read(apiClientProvider);
    _socket = ref.read(websocketProvider);

    _socket.on(SocketEvents.rideNew, _newRequest);
    _socket.on(SocketEvents.rideOfferRemoved, _offerRemoved);

    ref.onDispose(() {
      _socket.off(SocketEvents.rideNew, _newRequest);
      _socket.on(SocketEvents.rideOfferRemoved, _offerRemoved);
    });
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

  // WEBSOCKET
  void _newRequest(dynamic data) {
    try {
      final offer = RideOfferModel.fromJson(data as Map<String, dynamic>);
      developer.log('NEW OFFER: ${offer.rideId}', name: 'RideOffersNotifier');
      final currentOffers = state.valueOrNull ?? [];
      final exists = currentOffers.any((item) => item.rideId == offer.rideId);
      if (exists) {
        developer.log("OFFER EXTITS");
        return;
      }

      state = AsyncData([offer, ...currentOffers]);
    } catch (e, stackTrace) {
      developer.log(
        'FAILED TO PROCESS NEW RIDE REQUEST',
        name: 'RideOffersNotifier',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  //
  void _offerRemoved(dynamic data) {
    if (data is! Map) return;
    final rideId = data['rideId'] as String?;
    if (rideId == null) return;

    developer.log(
      'OFFER REMOVED (cancelled): $rideId',
      name: 'RideOffersNotifier',
    );
    removeOffer(rideId);
  }
}

final rideOffersProvider =
    AsyncNotifierProvider.autoDispose<RideOffersNotifier, List<RideOfferModel>>(
      RideOffersNotifier.new,
    );
