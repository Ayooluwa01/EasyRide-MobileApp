import 'dart:developer' as developer;

import 'package:easy_ride/app/services/accept_driver_offer.dart';
import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/core/socket/socket_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriverOffers extends Notifier<List<dynamic>> {
  late final Websocket _socket;

  String? _currentRideId;

  @override
  List<dynamic> build() {
    _socket = ref.read(websocketProvider);

    _socket.on(SocketEvents.driverOffers, _onDriverOffer);

    ref.onDispose(() {
      _socket.off(SocketEvents.driverOffers, _onDriverOffer);
    });

    return [];
  }

  void setRide(String rideId) {
    _currentRideId = rideId;
    state = [];
  }

  void _onDriverOffer(dynamic data) {
    final rideId = data['rideId'];
    if (_currentRideId == null || rideId != _currentRideId) {
      return;
    }
    state = [...state, data];
  }

  void clearOffers() {
    state = [];
    _currentRideId = null;
  }

  Future<dynamic> acceptOffer(dynamic offer) async {
    final rideId = (offer['rideId'] ?? _currentRideId)?.toString();
    final driverId = offer['driver']?['id']?.toString().trim();

    if (rideId == null || driverId == null) {
      developer.log('Error: Missing rideId ($rideId) or driverId ($driverId)');
      throw StateError('Missing rideId or driverId for this offer');
    }

    final driverOfferService = ref.read(acceptOfferProvider);
    final response = await driverOfferService.acceptOffer(rideId, driverId);
    developer.log('response.success = ${response.success}');
    if (response.success) {
      clearOffers();
    }

    return response;
  }

  Future<void> rejectOffer(dynamic offer) async {
    final rideId = (offer['rideId'] ?? _currentRideId)?.toString();
    final driverId = offer['driver']?['id']?.toString().trim();

    if (rideId == null || driverId == null) {
      developer.log('Error: Missing rideId ($rideId) or driverId ($driverId)');
      throw StateError('Missing rideId or driverId for this offer');
    }
    state = state.where((item) {
      return item['driver']?['id'] != driverId;
    }).toList();
    final driverOfferService = ref.read(acceptOfferProvider);
    await driverOfferService.rejectOffer(rideId, driverId);
  }
}

final driverOfferProvider = NotifierProvider<DriverOffers, List<dynamic>>(
  DriverOffers.new,
);
