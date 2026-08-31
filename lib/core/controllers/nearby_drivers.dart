import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/core/socket/socket_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NearbyDrivers extends Notifier<dynamic> {
  late final Websocket _socket;

  @override
  dynamic build() {
    _socket = ref.read(websocketProvider);
    _socket.on(SocketEvents.nearbyDrivers, _handlenearbydrivers);

    ref.onDispose(() {
      _socket.off(SocketEvents.nearbyDrivers, _handlenearbydrivers);
    });

    return null;
  }

  void _handlenearbydrivers(dynamic data) {
    state = data;
  }
}

final nearbyDriversProvider = NotifierProvider<NearbyDrivers, dynamic>(
  NearbyDrivers.new,
);
