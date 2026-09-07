import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverActiveRideScreen extends ConsumerStatefulWidget {
  const DriverActiveRideScreen({super.key});

  @override
  ConsumerState<DriverActiveRideScreen> createState() =>
      _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState
    extends ConsumerState<DriverActiveRideScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userLatLng = ref.watch(userLatLngProvider);
    final isLocationLoading = userLatLng == null;
    final cameraTarget = LatLng(userLatLng!.latitude, userLatLng.longitude);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: cameraTarget),
          ),
        ],
      ),
    );
  }
}
