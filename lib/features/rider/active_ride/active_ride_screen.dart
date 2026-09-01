import 'dart:developer' as developer;
import 'package:easy_ride/core/controllers/active_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveRideScreen extends ConsumerStatefulWidget {
  final String rideId;
  const ActiveRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('ActiveRideScreen initialized with rideId: ${widget.rideId}');
    ref.read(activeRideProvider.notifier).joinRide(widget.rideId);
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(activeRideProvider);
    final driverLocation = ride?['driverLocation'];
    final latitude = driverLocation?['latitude'];
    final longitude = driverLocation?['longitude'];

    return Scaffold(
      appBar: AppBar(title: const Text('Active Ride')),
      body: Center(child: Text('Driver Location: $latitude, $longitude')),
    );
  }
}
