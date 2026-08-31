import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/core/socket/socket_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriverOffers extends Notifier<dynamic> {
  late final Websocket _socket;

  @override
  dynamic build() {
    _socket = ref.read(websocketProvider);
    _socket.on(SocketEvents.driverOffers, _ondriveroffers);

    ref.onDispose(() {
      _socket.off(SocketEvents.driverOffers, _ondriveroffers);
    });
  }

  void _ondriveroffers(dynamic data) {
    state = data;
  }
}

final driverOfferProvider = NotifierProvider<DriverOffers, dynamic>(
  DriverOffers.new,
);
