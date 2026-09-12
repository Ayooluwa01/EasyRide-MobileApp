import 'dart:async';
import 'dart:developer';

import 'package:easy_ride/app/services/location_service.dart';
import 'package:easy_ride/app/services/websocket.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

const storage = FlutterSecureStorage();
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: backgroundOnStart,
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: backgroundOnStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void backgroundOnStart(ServiceInstance service) {
  log(' BACKGROUND SERVICE STARTED');

  final websocket = Websocket();
  DateTime? lastLocationTime;
  StreamSubscription<Position>? locationSubscription;

  Future<void> startTracking() async {
    try {
      final accessToken = await storage.read(key: 'access-token');
      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      websocket.initialize(accessToken);
      if (locationSubscription != null) {
        log('BACKGROUND: Tracking already running');
        return;
      }
      locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 50,
            ),
          ).listen(
            (position) {
              // get current time
              final currtime = DateTime.now();

              // if the difference between current and prev is less than 5 secs prev
              if (lastLocationTime != null &&
                  currtime.difference(lastLocationTime!).inSeconds < 5) {
                // log('BACKGROUND: Location throttled');
                return;
              }
              if (!websocket.isConnected) {
                log('BACKGROUND: WebSocket disconnected');
                return;
              }
              lastLocationTime = currtime;

              websocket.emit('driver:location', {
                'lat': position.latitude,
                'lng': position.longitude,
              });
            },
            onError: (error, stackTrace) {
              log('BACKGROUND LOCATION ERROR: $error', stackTrace: stackTrace);
            },
          );

      log('BACKGROUND: Location stream started');
    } catch (e, stackTrace) {
      log('BACKGROUND TRACKING ERROR: $e', stackTrace: stackTrace);
    }
  }

  startTracking();

  service.on('stop_tracking').listen((event) async {
    log('BACKGROUND: STOP TRACKING');

    await locationSubscription?.cancel();
    locationSubscription = null;

    websocket.disconnect();

    service.stopSelf();
  });
}
