import 'dart:developer' as developer;

import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/core/socket/socket_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveRideNotifier extends Notifier<Map<String, dynamic>?> {
  late final Websocket _socket;

  @override
  Map<String, dynamic>? build() {
    _socket = ref.read(websocketProvider);
    _socket.on(SocketEvents.rideMatched, _onRideMatched);
    _socket.on(SocketEvents.rideDriverArrived, _onDriverArrived);
    _socket.on(SocketEvents.rideStarted, _onRideStarted);
    _socket.on(SocketEvents.rideDestinationReached, _onDestinationReached);
    _socket.on(SocketEvents.rideCompleted, _onRideCompleted);
    _socket.on(SocketEvents.rideCancelled, _onRideCancelled);
    _socket.on(SocketEvents.driverLocation, _onDriverLocation);

    ref.onDispose(() {
      _socket.off(SocketEvents.rideMatched, _onRideMatched);
      _socket.off(SocketEvents.rideDriverArrived, _onDriverArrived);
      _socket.off(SocketEvents.rideStarted, _onRideStarted);
      _socket.off(SocketEvents.rideDestinationReached, _onDestinationReached);
      _socket.off(SocketEvents.rideCompleted, _onRideCompleted);
      _socket.off(SocketEvents.rideCancelled, _onRideCancelled);
      _socket.off(SocketEvents.driverLocation, _onDriverLocation);
    });

    return null;
  }

  // ============================================================
  // ============================================================

  void setRide(Map<String, dynamic> ride) {
    state = Map<String, dynamic>.from(ride);
    developer.log(
      'Active ride set: ${ride['rideId'] ?? ride['id']}',
      name: 'ActiveRide',
    );
  }

  void clear() {
    state = null;
    developer.log('Active ride cleared', name: 'ActiveRide');
  }

  // ============================================================
  // RIDE MATCHED
  // ============================================================

  void _onRideMatched(dynamic data) {
    if (data is! Map) return;
    final incoming = Map<String, dynamic>.from(data);
    state = {...?state, ...incoming};
    developer.log('RIDE MATCHED: $incoming', name: 'ActiveRide');
  }

  // ============================================================
  // DRIVER ARRIVED
  // ============================================================

  void _onDriverArrived(dynamic data) {
    if (data is! Map) return;
    final incoming = Map<String, dynamic>.from(data);
    if (!_belongsToCurrentRide(incoming)) {
      return;
    }
    state = {...?state, ...incoming, 'status': 'DRIVER_ARRIVED'};
    developer.log('DRIVER ARRIVED', name: 'ActiveRide');
  }

  // ============================================================
  // RIDE STARTED
  // ============================================================

  void _onRideStarted(dynamic data) {
    if (data is! Map) return;
    final incoming = Map<String, dynamic>.from(data);
    if (!_belongsToCurrentRide(incoming)) {
      return;
    }
    state = {...?state, ...incoming, 'status': 'IN_PROGRESS'};
    developer.log('RIDE STARTED', name: 'ActiveRide');
  }

  // ============================================================
  // DESTINATION REACHED
  // ============================================================

  void _onDestinationReached(dynamic data) {
    if (data is! Map) return;
    final incoming = Map<String, dynamic>.from(data);
    if (!_belongsToCurrentRide(incoming)) {
      return;
    }
    state = {...?state, 'destinationReached': true};
    developer.log('DESTINATION REACHED', name: 'ActiveRide');
  }

  // ============================================================
  // RIDE COMPLETED
  // ============================================================

  void _onRideCompleted(dynamic data) {
    if (data is! Map) return;
    final incoming = Map<String, dynamic>.from(data);
    if (!_belongsToCurrentRide(incoming)) {
      return;
    }

    state = {...?state, ...incoming, 'status': 'COMPLETED'};
    developer.log('RIDE COMPLETED', name: 'ActiveRide');
  }

  // ============================================================
  // RIDE CANCELLED
  // ============================================================

  void _onRideCancelled(dynamic data) {
    if (data is! Map) return;
    final incoming = Map<String, dynamic>.from(data);
    if (!_belongsToCurrentRide(incoming)) {
      return;
    }

    developer.log('RIDE CANCELLED', name: 'ActiveRide');
    state = null;
  }

  // ============================================================
  // DRIVER LOCATION
  // ============================================================

  void _onDriverLocation(dynamic data) {
    if (data is! Map) return;
    final incoming = Map<String, dynamic>.from(data);
    if (!_belongsToCurrentRide(incoming)) {
      return;
    }
    state = {
      ...?state,
      'driverLocation': {
        'latitude': incoming['latitude'],
        'longitude': incoming['longitude'],
        'heading': incoming['heading'],
        'speed': incoming['speed'],
        'accuracy': incoming['accuracy'],
      },
    };
  }

  bool _belongsToCurrentRide(Map<String, dynamic> data) {
    if (state == null) {
      return false;
    }
    final currentRideId = state!['rideId'] ?? state!['id'];
    final incomingRideId = data['rideId'];
    return currentRideId != null && incomingRideId == currentRideId;
  }
}

final activeRideProvider =
    NotifierProvider<ActiveRideNotifier, Map<String, dynamic>?>(
      ActiveRideNotifier.new,
    );
