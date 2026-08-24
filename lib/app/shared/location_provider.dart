import 'dart:async';
import 'package:easy_ride/app/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationNotifier extends StreamNotifier<Position> with LocationService {
  @override
  Stream<Position> build() async* {
    final initialPosition = await determinePosition();
    yield initialPosition;
    yield* trackLocation();
  }

  Future<void> refreshLocation() async {
    final updatedPosition = await determinePosition();
    state = AsyncValue.data(updatedPosition);
  }
}

final locationProvider = StreamNotifierProvider<LocationNotifier, Position>(
  LocationNotifier.new,
);

final userLatLngProvider = Provider<LatLng?>((ref) {
  final asyncPosition = ref.watch(locationProvider);
  return asyncPosition.when(
    data: (pos) => LatLng(pos.latitude, pos.longitude),
    loading: () => null,
    error: (_, __) => null,
  );
});
