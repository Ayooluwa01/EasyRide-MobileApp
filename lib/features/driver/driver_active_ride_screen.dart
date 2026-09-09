import 'dart:developer' as developer;

import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:easy_ride/app/services/get_ride_by_id.dart';
import 'package:easy_ride/app/services/route_service.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:easy_ride/core/controllers/active_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverActiveRideScreen extends ConsumerStatefulWidget {
  const DriverActiveRideScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<DriverActiveRideScreen> createState() =>
      _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState
    extends ConsumerState<DriverActiveRideScreen> {
  // Google Maps controller.
  GoogleMapController? _mapController;

  // Currently displayed road polylines.
  Set<Polyline> _routePolylines = {};

  // Driver + pickup markers.
  final Set<Marker> _markers = {};
  LatLng? _lastRouteOrigin;

  // Prevent multiple route requests from running at the
  // same time.
  bool _isFetchingRoute = false;

  // Minimum distance the driver needs to move before
  // requesting another route.
  static const double _rerouteDistanceMeters = 50;

  // Default Lagos location if the device location
  // isn't available yet.
  static const LatLng _defaultLocation = LatLng(6.5244, 3.3792);

  @override
  void initState() {
    super.initState();

    debugPrint('DriverActiveRideScreen initialized: ${widget.rideId}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRideidetails();
    });
  }

  // ============================================================
  // INITIAL RIDE SETUP
  // ============================================================

  Future<void> getRideidetails() async {
    developer.log(
      'Starting ride initialization: ${widget.rideId}',
      name: 'ActiveRide',
    );

    final activeRide = ref.read(activeRideProvider.notifier);

    // Initialize the active ride with the ride ID.
    //
    // This is important because your WebSocket events
    // contain rideId and ActiveRideNotifier uses it to
    // determine whether an event belongs to this ride.
    activeRide.setRide({'id': widget.rideId, 'rideId': widget.rideId});

    developer.log('ActiveRide state initialized', name: 'ActiveRide');

    // Join the WebSocket room for this ride.
    activeRide.joinRide(widget.rideId);

    developer.log('Joined ride: ${widget.rideId}', name: 'ActiveRide');

    developer.log('Fetching ride details...', name: 'ActiveRide');

    // Fetch the current ride from the API.
    await ref.read(getRideByIdProvider.notifier).fetchRide(widget.rideId);

    final rideState = ref.read(getRideByIdProvider);

    developer.log('Ride provider state: $rideState', name: 'ActiveRide');

    final ride = rideState.valueOrNull;

    if (ride == null) {
      developer.log('Ride not found', name: 'ActiveRide');
      return;
    }

    developer.log('Ride fetched successfully: ${ride.id}', name: 'ActiveRide');

    // Store the initial ride information in ActiveRideProvider.
    activeRide.setRide({
      'id': ride.id,
      'rideId': ride.id,
      'status': ride.status,

      'driverLocation': ride.driverLocation != null
          ? {
              'latitude': ride.driverLocation!.latitude,
              'longitude': ride.driverLocation!.longitude,
              'heading': ride.driverLocation!.heading,
              'speed': ride.driverLocation!.speed,
              'accuracy': ride.driverLocation!.accuracy,
            }
          : null,
    });

    // Create the initial driver and pickup markers.
    _setRideMarkers(ride);

    // Fetch the initial road route:
    //
    // Driver current location
    //          ↓
    //       road route
    //          ↓
    //      rider pickup
    await _fetchRoadRoute(ride);
  }

  // ============================================================
  // INITIAL MARKERS
  // ============================================================

  void _setRideMarkers(dynamic ride) {
    final driverLocation = ride.driverLocation;
    final pickupLocation = ride.pickupLocation;

    if (driverLocation == null) {
      developer.log(
        'Cannot create driver marker: driver location is null',
        name: 'Map',
      );
    }

    if (pickupLocation == null) {
      developer.log(
        'Cannot create pickup marker: pickup location is null',
        name: 'Map',
      );
    }

    if (driverLocation == null || pickupLocation == null) {
      return;
    }

    final driverPosition = LatLng(
      driverLocation.latitude,
      driverLocation.longitude,
    );

    final pickupPosition = LatLng(
      pickupLocation.latitude,
      pickupLocation.longitude,
    );

    developer.log(
      'Driver marker: '
      '${driverPosition.latitude}, '
      '${driverPosition.longitude}',
      name: 'Map',
    );

    developer.log(
      'Pickup marker: '
      '${pickupPosition.latitude}, '
      '${pickupPosition.longitude}',
      name: 'Map',
    );

    if (!mounted) {
      return;
    }

    // Save the location from which the initial route was requested.
    _lastRouteOrigin = driverPosition;

    setState(() {
      _markers
        ..clear()
        // DRIVER MARKER
        ..add(
          Marker(
            markerId: const MarkerId('driver'),
            position: driverPosition,
            infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'Driver',
            ),
          ),
        )
        // PICKUP MARKER
        ..add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickupPosition,
            infoWindow: const InfoWindow(
              title: 'Pickup Location',
              snippet: 'Rider pickup',
            ),
          ),
        );
    });
  }

  // ============================================================
  // WEBSOCKET DRIVER LOCATION HANDLER
  // ============================================================

  void _handleDriverLocationUpdate(Map<String, dynamic>? ride) {
    if (ride == null) {
      return;
    }

    final driverLocation = ride['driverLocation'];

    if (driverLocation == null) {
      return;
    }

    final latitude = driverLocation['latitude'];
    final longitude = driverLocation['longitude'];

    if (latitude == null || longitude == null) {
      developer.log('Invalid driver location received', name: 'Map');
      return;
    }

    final position = LatLng(
      (latitude as num).toDouble(),
      (longitude as num).toDouble(),
    );

    developer.log(
      'New driver location: '
      '${position.latitude}, ${position.longitude}',
      name: 'Map',
    );

    // IMPORTANT:
    //
    // The marker moves immediately.
    //
    // We don't wait for the route API.
    _updateDriverMarker(position);

    // Separately determine whether a new road route
    // should be requested.
    _checkIfRerouteIsNeeded(position);
  }

  // ============================================================
  // UPDATE DRIVER MARKER
  // ============================================================

  void _updateDriverMarker(LatLng position) {
    if (!mounted) {
      return;
    }

    setState(() {
      // Remove only the old driver marker.
      //
      // The pickup marker remains untouched.
      _markers.removeWhere((marker) => marker.markerId.value == 'driver');

      // Add the driver at the new location.
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: position,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Driver',
          ),
        ),
      );
    });

    developer.log('Driver marker updated', name: 'Map');
  }

  // ============================================================
  // CHECK WHETHER WE NEED TO RECALCULATE THE ROUTE
  // ============================================================

  void _checkIfRerouteIsNeeded(LatLng currentPosition) {
    // This can happen if we receive a WebSocket location
    // before the initial REST route has been established.
    if (_lastRouteOrigin == null) {
      _lastRouteOrigin = currentPosition;

      developer.log(
        'No previous route origin. Setting current location '
        'as route origin.',
        name: 'Route',
      );

      return;
    }

    // Calculate how far the driver has moved from the
    // location used for the last route request.
    final distance = Geolocator.distanceBetween(
      _lastRouteOrigin!.latitude,
      _lastRouteOrigin!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    developer.log(
      'Driver moved ${distance.toStringAsFixed(1)}m '
      'since last route calculation',
      name: 'Route',
    );

    // Driver hasn't moved enough.
    //
    // We still move the marker, but don't request
    // another route.
    if (distance < _rerouteDistanceMeters) {
      return;
    }

    developer.log(
      'Driver moved more than '
      '$_rerouteDistanceMeters meters. '
      'Recalculating route.',
      name: 'Route',
    );

    // Update the route origin immediately.
    _lastRouteOrigin = currentPosition;

    // Request the new route.
    _rerouteFromCurrentLocation(currentPosition);
  }

  // ============================================================
  // RECALCULATE ROUTE
  // ============================================================

  Future<void> _rerouteFromCurrentLocation(LatLng driverPosition) async {
    // Don't allow multiple route requests at the same time.
    //
    // Example:
    //
    // 50m → request starts
    // 55m → another websocket event
    // 60m → another websocket event
    //
    // We don't want 3 HTTP route requests running together.
    if (_isFetchingRoute) {
      developer.log('Route request already running. Skipping.', name: 'Route');

      return;
    }

    _isFetchingRoute = true;

    try {
      // Get the latest ride details.
      final ride = ref.read(getRideByIdProvider).valueOrNull;

      if (ride == null) {
        developer.log(
          'Cannot reroute: ride details unavailable',
          name: 'Route',
        );
        return;
      }

      // Currently we're navigating:
      //
      // DRIVER → PICKUP
      //
      // Later, when the ride becomes IN_PROGRESS,
      // this target can be changed to DROP-OFF.
      final pickupLocation = ride.pickupLocation;

      if (pickupLocation == null) {
        developer.log('Cannot reroute: pickup location is null', name: 'Route');
        return;
      }

      final request = GetRouteRequest(
        originLng: driverPosition.longitude,
        originLat: driverPosition.latitude,
        destLng: pickupLocation.longitude,
        destLat: pickupLocation.latitude,
      );

      developer.log('Requesting new route...', name: 'Route');

      developer.log(
        'New origin: '
        '${driverPosition.latitude}, '
        '${driverPosition.longitude}',
        name: 'Route',
      );

      developer.log(
        'Destination: '
        '${pickupLocation.latitude}, '
        '${pickupLocation.longitude}',
        name: 'Route',
      );

      final response = await ref.read(routeServiceProvider).getRoute(request);

      final route = response.data;

      developer.log(
        'New route distance: '
        '${route.distanceMeters} meters',
        name: 'Route',
      );

      developer.log(
        'New route duration: '
        '${route.durationSeconds} seconds',
        name: 'Route',
      );

      // Decode the encoded polyline.
      final decoded = PolylinePoints.decodePolyline(route.polyline);

      if (decoded.isEmpty) {
        developer.log('New route decoded to 0 points', name: 'Route');
        return;
      }

      // Convert PointLatLng → Google Maps LatLng.
      final points = decoded
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(growable: false);

      developer.log(
        'New route decoded into ${points.length} points',
        name: 'Route',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _routePolylines = {
          Polyline(
            polylineId: const PolylineId('driver-rider-route'),
            points: points,
            color: Colors.blue,
            width: 5,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
      });

      developer.log('Road polyline updated', name: 'Route');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to recalculate route',
        name: 'Route',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      // Allow another route request after this one finishes.
      _isFetchingRoute = false;
    }
  }

  // ============================================================
  // INITIAL ROAD ROUTE
  // ============================================================

  Future<void> _fetchRoadRoute(dynamic ride) async {
    try {
      final driverLocation = ride.driverLocation;
      final pickupLocation = ride.pickupLocation;

      if (driverLocation == null) {
        developer.log(
          'Cannot fetch route: driver location is null',
          name: 'Route',
        );
        return;
      }

      if (pickupLocation == null) {
        developer.log(
          'Cannot fetch route: pickup location is null',
          name: 'Route',
        );
        return;
      }

      final driverPosition = LatLng(
        driverLocation.latitude,
        driverLocation.longitude,
      );

      // Remember where this route started.
      //
      // Future WebSocket updates will be compared
      // against this location.
      _lastRouteOrigin = driverPosition;

      final request = GetRouteRequest(
        originLng: driverLocation.longitude,
        originLat: driverLocation.latitude,
        destLng: pickupLocation.longitude,
        destLat: pickupLocation.latitude,
      );

      developer.log('Fetching initial road route...', name: 'Route');

      developer.log(
        'Origin: '
        '${driverLocation.latitude}, '
        '${driverLocation.longitude}',
        name: 'Route',
      );

      developer.log(
        'Destination: '
        '${pickupLocation.latitude}, '
        '${pickupLocation.longitude}',
        name: 'Route',
      );

      final response = await ref.read(routeServiceProvider).getRoute(request);

      final route = response.data;

      developer.log(
        'Route distance: '
        '${route.distanceMeters} meters',
        name: 'Route',
      );

      developer.log(
        'Route duration: '
        '${route.durationSeconds} seconds',
        name: 'Route',
      );

      developer.log(
        'Polyline length: '
        '${route.polyline.length}',
        name: 'Route',
      );

      // Decode encoded polyline.
      final decoded = PolylinePoints.decodePolyline(route.polyline);

      if (decoded.isEmpty) {
        developer.log('Route polyline decoded to 0 points', name: 'Route');
        return;
      }

      // Convert decoded points to Google Maps LatLng.
      final points = decoded
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(growable: false);

      developer.log('Decoded route points: ${points.length}', name: 'Route');

      if (!mounted) {
        return;
      }

      setState(() {
        _routePolylines = {
          Polyline(
            polylineId: const PolylineId('driver-rider-route'),
            points: points,
            color: Colors.blue,
            width: 5,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
      });

      developer.log('Road route added to Google Maps', name: 'Route');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch road route',
        name: 'Route',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, dynamic>?>(activeRideProvider, (previous, next) {
      _handleDriverLocationUpdate(next);
    });

    final userLatLng = ref.watch(userLatLngProvider);
    final cameraTarget = userLatLng != null
        ? LatLng(userLatLng.latitude, userLatLng.longitude)
        : _defaultLocation;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: cameraTarget,
              zoom: 14,
            ),

            // Driver + pickup markers.
            markers: _markers,

            // Current road route.
            polylines: _routePolylines,

            onMapCreated: (controller) {
              _mapController = controller;

              developer.log('Google Map controller initialized', name: 'Map');
            },

            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Simple ride ID display for now.
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ride ID: ${widget.rideId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
