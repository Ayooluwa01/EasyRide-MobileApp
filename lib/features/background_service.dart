import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:easy_ride/app/services/websocket.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
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
      autoStart: false,
      onForeground: backgroundOnStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

Future<bool> _canTrackLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) return false;
  final permission = await Geolocator.checkPermission();
  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}

LocationSettings _buildLocationSettings() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
      activityType: ActivityType.automotiveNavigation,
      pauseLocationUpdatesAutomatically: false,
      allowBackgroundLocationUpdates: true,
      showBackgroundLocationIndicator: true,
    );
  }
  return const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50,
  );
}

@pragma('vm:entry-point')
void backgroundOnStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  log(' BACKGROUND SERVICE STARTED');

  final websocket = Websocket();
  DateTime? lastLocationTime;
  StreamSubscription<Position>? locationSubscription;
  var isStarting = false;

  Future<void> startTracking() async {
    if (isStarting) return;
    isStarting = true;

    try {
      final accessToken = await storage.read(key: 'access-token');
      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      if (!await _canTrackLocation()) {
        log('BACKGROUND: no location permission, not tracking');
        return;
      }

      if (locationSubscription != null) {
        log('BACKGROUND: Tracking already running');
        return;
      }

      websocket.initialize(accessToken);

      locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: _buildLocationSettings(),
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
            onError: (error, stackTrace) async {
              log('BACKGROUND LOCATION ERROR: $error', stackTrace: stackTrace);
              // Clear the dead subscription so the next startTracking() can
              // retry instead of being stuck on "already running".
              await locationSubscription?.cancel();
              locationSubscription = null;
            },
          );

      log('BACKGROUND: Location stream started');
    } catch (e, stackTrace) {
      log('BACKGROUND TRACKING ERROR: $e', stackTrace: stackTrace);
    } finally {
      isStarting = false;
    }
  }

  startTracking();

  service.on('start_tracking').listen((event) {
    startTracking();
  });

  service.on('stop_tracking').listen((event) async {
    log('BACKGROUND: STOP TRACKING');

    await locationSubscription?.cancel();
    locationSubscription = null;

    websocket.disconnect();

    service.stopSelf();
  });
}
