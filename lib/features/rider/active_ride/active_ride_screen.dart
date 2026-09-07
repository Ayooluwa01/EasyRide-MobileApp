// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:easy_ride/app/models/get_ride_model.dart';
import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/get_ride_by_id.dart';
import 'package:easy_ride/app/services/route_service.dart';
import 'package:easy_ride/app/shared/icon_to_bipmap.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:easy_ride/app/theme/app_theme.dart';
import 'package:easy_ride/core/controllers/active_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActiveRideScreen extends ConsumerStatefulWidget {
  final String rideId;

  const ActiveRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  // ============================================================
  // GOOGLE MAPS
  // ============================================================

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Set<Polyline> _routePolylines = {};
  BitmapDescriptor? riderIcon;
  BitmapDescriptor? driverIcon;

  // ============================================================
  // ROUTE THROTTLING — avoid re-calling Directions on every tiny
  // driver GPS jitter; only refetch when the driver has moved a
  // meaningful distance, debounced.
  // ============================================================

  ({double lat, double lng})? _lastRoutedDriverPosition;
  Timer? _routeDebounce;
  bool _fetchingRoute = false;

  // ============================================================
  // UPDATE CONTROL
  // ============================================================

  bool _mapReady = false;
  bool _disposed = false;
  bool _hasCenteredOnDriver = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(activeRideProvider, (_, _) {
      _updateMarkersAndRoute();
    });
    ref.listenManual(locationProvider, (_, _) {
      _updateMarkersAndRoute();
    });

    // listen to ride in progress status from websocket or if the inital rest api status response is in_Progress
    ref.listenManual(activeRideProvider, (previous, next) {
      final status = next?['status'];

      if (status == 'IN_PROGRESS') {
        _updateMarkersAndRoute();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_disposed) return;

      final activeRide = ref.read(activeRideProvider.notifier);
      activeRide.setRide({'id': widget.rideId, 'rideId': widget.rideId});
      activeRide.joinRide(widget.rideId);
      await ref.read(getRideByIdProvider.notifier).fetchRide(widget.rideId);
      if (_disposed) return;
      final ride = ref.read(getRideByIdProvider).valueOrNull;
      if (ride == null) {
        developer.log('Ride not found', name: 'ActiveRide');
        return;
      }
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

      _loadRiderIcon();
    });
  }

  Future<void> _loadRiderIcon() async {
    final icon = await iconToBitmapDescriptor(
      Icons.person_pin_circle,
      size: 50,
      color: Color.from(alpha: 1, red: 0.094, green: 0.886, blue: 0.471),
    );
    final taxiIcon = await iconToBitmapDescriptor(
      Icons.local_taxi,
      size: 30,
      color: Colors.black38,
    );

    if (mounted) {
      setState(() {
        riderIcon = icon;
        driverIcon = taxiIcon;
      });

      _updateMarkersAndRoute();
    }
  }
  // ============================================================
  // UPDATE MARKERS + ROUTE
  // ============================================================

  Future<void> _updateMarkersAndRoute() async {
    if (_disposed || !_mapReady) return;

    final userPosition = ref.read(locationProvider).value;
    final socketRide = ref.read(activeRideProvider);
    final rideDetails = ref.read(getRideByIdProvider).valueOrNull;

    final socketDriverLocation = socketRide?['driverLocation'];
    final restDriverLocation = rideDetails?.driverLocation;

    final dynamic socketLatitude = socketDriverLocation?['latitude'];

    final dynamic socketLongitude = socketDriverLocation?['longitude'];

    final double? driverLatitude = socketLatitude is num
        ? socketLatitude.toDouble()
        : restDriverLocation?.latitude;

    final double? driverLongitude = socketLongitude is num
        ? socketLongitude.toDouble()
        : restDriverLocation?.longitude;

    final updatedMarkers = <Marker>{};

    // ============================================================
    // RIDER MARKER
    // ============================================================

    if (userPosition != null) {
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId('rider'),
          position: LatLng(userPosition.latitude, userPosition.longitude),
          icon:
              riderIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
        ),
      );
    }

    // ============================================================
    // DRIVER MARKER
    // ============================================================

    if (driverLatitude != null && driverLongitude != null) {
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(driverLatitude, driverLongitude),
          icon:
              driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(updatedMarkers);
      });
    }

    // ============================================================
    // ROUTE
    // ============================================================

    if (driverLatitude == null || driverLongitude == null) {
      return;
    }

    final status = socketRide?['status'] ?? rideDetails?.status;

    double? routeDestinationLat;
    double? routeDestinationLng;

    if (status == 'IN_PROGRESS') {
      // Driver → Destination
      routeDestinationLat = rideDetails?.dropoffLocation!.latitude;
      routeDestinationLng = rideDetails?.dropoffLocation!.longitude;
    } else {
      // Driver → Rider / Pickup

      routeDestinationLat = userPosition?.latitude;
      routeDestinationLng = userPosition?.longitude;
    }

    if (routeDestinationLat == null || routeDestinationLng == null) {
      return;
    }

    _maybeRefetchRoute(
      riderLat: routeDestinationLat,
      riderLng: routeDestinationLng,
      driverLat: driverLatitude,
      driverLng: driverLongitude,
    );
  }
  // ============================================================
  // ROAD ROUTE — throttled Directions call, not a straight line
  // ============================================================

  void _maybeRefetchRoute({
    required double riderLat,
    required double riderLng,
    required double driverLat,
    required double driverLng,
  }) {
    final last = _lastRoutedDriverPosition;
    if (last != null) {
      final movedMeters = _distanceMeters(
        last.lat,
        last.lng,
        driverLat,
        driverLng,
      );
      // Skip re-fetching for small GPS jitter — only refresh the route
      // once the driver has moved far enough to meaningfully change it.
      if (movedMeters < 70) return;
    }

    _routeDebounce?.cancel();
    _routeDebounce = Timer(const Duration(seconds: 1), () {
      _fetchRoadRoute(
        riderLat: riderLat,
        riderLng: riderLng,
        driverLat: driverLat,
        driverLng: driverLng,
      );
    });
  }

  Future<void> _fetchRoadRoute({
    required double riderLat,
    required double riderLng,
    required double driverLat,
    required double driverLng,
  }) async {
    if (_fetchingRoute || _disposed) return;
    _fetchingRoute = true;

    try {
      final request = GetRouteRequest(
        originLng: driverLng,
        originLat: driverLat,
        destLng: riderLng,
        destLat: riderLat,
      );

      final response = await ref.read(routeServiceProvider).getRoute(request);
      final route = response.data;

      final decoded = PolylinePoints.decodePolyline(route.polyline);
      final points = decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false);

      if (!mounted) return;
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

      _lastRoutedDriverPosition = (lat: driverLat, lng: driverLng);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch road route',
        name: 'ActiveRideMap',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _fetchingRoute = false;
    }
  }

  double _distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLng = (lng2 - lng1) * (math.pi / 180);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  // ============================================================
  // MAP CREATED
  // ============================================================

  Future<void> _onMapCreated(GoogleMapController controller) async {
    if (_disposed) return;
    _mapController = controller;
    _mapReady = true;
    await _updateMarkersAndRoute();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final socketRide = ref.watch(activeRideProvider);
    final rideDetails = ref.watch(getRideByIdProvider).valueOrNull;
    final userLocation = ref.watch(locationProvider);
    final userPosition = userLocation.value;
    final socketDriverLocation = socketRide?['driverLocation'];
    final restDriverLocation = rideDetails?.driverLocation;
    final dynamic socketLatitude = socketDriverLocation?['latitude'];
    final dynamic socketLongitude = socketDriverLocation?['longitude'];
    final double? latitude = socketLatitude is num
        ? socketLatitude.toDouble()
        : restDriverLocation?.latitude;
    final double? longitude = socketLongitude is num
        ? socketLongitude.toDouble()
        : restDriverLocation?.longitude;
    final status = socketRide?['status'] ?? rideDetails?.status;

    // listen to when ride has started/in-progress or if the rest api is ride status is in-progres
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            key: const ValueKey('active_ride_map'),
            initialCameraPosition: CameraPosition(
              target: LatLng(
                userPosition?.latitude ?? 6.5244,
                userPosition?.longitude ?? 3.3792,
              ),
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _routePolylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
          ),

          if (latitude == null || longitude == null)
            const Center(child: CircularProgressIndicator()),

          // ========================================================
          // BOTTOM SHEET
          // ========================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF161616)
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  if (status == 'MATCHED' ||
                      status == 'DRIVER_SELECTED' ||
                      status == 'DRIVER_ON_THE_WAY')
                    _DriverOnTheWay(
                      theme: theme,
                      rideDetails: rideDetails,
                      context: context,
                    )
                  else if (status == 'DRIVER_ARRIVED')
                    _DriverArrived(theme: theme, rideDetails: rideDetails)
                  else if (status == 'IN_PROGRESS')
                    _RideInProgress(theme: theme, rideDetails: rideDetails)
                  else if (status == 'DESTINATION_REACHED' ||
                      status == 'COMPLETED')
                    _RideCompleted(theme: theme, rideDetails: rideDetails)
                  else
                    _DriverOnTheWay(
                      theme: theme,
                      rideDetails: rideDetails,
                      context: context,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposed = true;
    _mapReady = false;
    _routeDebounce?.cancel();
    _mapController = null;
    super.dispose();
  }
}

// ==================================================================
// SHARED HELPERS (unchanged — no Mapbox dependency)
// ==================================================================

String _formatNaira(double? amount) {
  final value = amount ?? 0;
  final wholePart = value.round().toString();

  final buffer = StringBuffer();
  for (var i = 0; i < wholePart.length; i++) {
    final indexFromEnd = wholePart.length - i;
    buffer.write(wholePart[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }

  return '₦$buffer';
}

String _paymentMethodLabel(String? method) {
  switch (method) {
    case 'CARD':
      return 'Card';
    case 'WALLET':
      return 'Wallet';
    case 'CASH':
    case 'TRANSFER':
      return 'Transfer';
    default:
      return 'Cash';
  }
}

IconData _paymentMethodIcon(String? method) {
  switch (method) {
    case 'CARD':
      return Icons.credit_card;
    case 'WALLET':
      return Icons.account_balance_wallet;
    case 'CASH':
    case 'Transfer':
      return Icons.credit_card;
    default:
      return Icons.account_balance_wallet_outlined;
  }
}

String _vehicleSummary(RideDriverInfo? driver) {
  if (driver == null) return 'Vehicle details unavailable';

  final parts = <String>[
    if (driver.vehicleColor != null) driver.vehicleColor!,
    if (driver.vehicleType != null) driver.vehicleType!,
  ];

  return parts.isEmpty ? 'Vehicle details unavailable' : parts.join(' ');
}

Widget _StatusPill({
  required ThemeData theme,
  required String label,
  required IconData icon,
  Color? color,
}) {
  final accent = color ?? theme.colorScheme.primary;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: accent),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accent,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

Widget _RoundIconAction({
  required ThemeData theme,
  required IconData icon,
  required VoidCallback onPressed,
  Color? background,
}) {
  final colorScheme = theme.colorScheme;

  return Material(
    color: background ?? colorScheme.onSurface.withValues(alpha: 0.06),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: colorScheme.onSurface),
      ),
    ),
  );
}

Widget _SoftDivider(ThemeData theme) {
  return Divider(
    height: 28,
    thickness: 1,
    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
  );
}

Widget _AvatarWithDot({
  required String name,
  required String? imageUrl,
  required Color dotColor,
  double radius = 26,
}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      ProfilePicture(
        name: name,
        radius: radius,
        fontsize: radius - 4,
        img: imageUrl ?? '',
      ),
      Positioned(
        right: -1,
        bottom: -1,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    ],
  );
}

Widget _StarRow({required ThemeData theme, int filled = 5}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(
          index < filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 30,
          color: index < filled
              ? const Color(0xFFFFB020)
              : theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
      );
    }),
  );
}

// ==================================================================
// DRIVER ON THE WAY
// ==================================================================
Widget _DriverOnTheWay({
  required ThemeData theme,
  required GetRideByIdModel? rideDetails,
  required BuildContext context,
}) {
  final colorScheme = theme.colorScheme;
  final driver = rideDetails?.driver;
  final driverUser = driver?.user;

  return Column(
    children: [
      Row(
        children: [
          _StatusPill(
            theme: theme,
            icon: Icons.directions_car_filled,
            label: 'Driver on the way',
          ),
          const Spacer(),
        ],
      ),

      const SizedBox(height: 18),

      Row(
        children: [
          _AvatarWithDot(
            name: driverUser?.fullName ?? 'Driver',
            imageUrl: driverUser?.profilePhotoUrl,
            dotColor: (driver?.isOnline ?? false)
                ? const Color(0xFF22C55E)
                : colorScheme.onSurface.withValues(alpha: 0.3),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  driverUser?.fullName ?? 'Finding your driver…',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _vehicleSummary(driver),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    if (driver?.vehiclePlate != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          driver!.vehiclePlate!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _RoundIconAction(theme: theme, icon: Icons.call, onPressed: () {}),
          const SizedBox(width: 8),
          _RoundIconAction(
            theme: theme,
            icon: Icons.chat_bubble_outline,
            onPressed: () {
              context.push(RouteNames.chatscreen, extra: rideDetails?.id);
            },
          ),
        ],
      ),

      _SoftDivider(theme),

      Row(
        children: [
          Icon(
            _paymentMethodIcon(rideDetails?.paymentMethod),
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            _paymentMethodLabel(rideDetails?.paymentMethod),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Text(
            _formatNaira(rideDetails?.fareFinal ?? rideDetails?.fareEstimate),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: AppTheme.lightTheme.primaryColor,
            side: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          onPressed: () {},
          child: Text(
            'Cancel Ride',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    ],
  );
}

// ==================================================================
// DRIVER ARRIVED
// ==================================================================

Widget _DriverArrived({
  required ThemeData theme,
  required GetRideByIdModel? rideDetails,
}) {
  final colorScheme = theme.colorScheme;
  final driver = rideDetails?.driver;
  final driverUser = driver?.user;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _StatusPill(
        theme: theme,
        icon: Icons.check_circle,
        label: 'Driver has arrived',
        color: const Color(0xFF22C55E),
      ),

      const SizedBox(height: 16),

      Row(
        children: [
          _AvatarWithDot(
            name: driverUser?.fullName ?? 'Driver',
            imageUrl: driverUser?.profilePhotoUrl,
            dotColor: const Color(0xFF22C55E),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  driverUser?.fullName ?? 'Driver',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_vehicleSummary(driver)}${driver?.vehiclePlate != null ? ' • ${driver!.vehiclePlate}' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          _RoundIconAction(theme: theme, icon: Icons.call, onPressed: () {}),
        ],
      ),

      if (rideDetails?.pickupAddress != null) ...[
        _SoftDivider(theme),
        Row(
          children: [
            Icon(Icons.my_location, size: 18, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                rideDetails!.pickupAddress!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ] else
        const SizedBox(height: 20),

      const SizedBox(height: 20),

      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {},
          child: const Text(
            "I'm Ready",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ],
  );
}

// ==================================================================
// RIDE IN PROGRESS
// ==================================================================

Widget _RideInProgress({
  required ThemeData theme,
  required GetRideByIdModel? rideDetails,
}) {
  final colorScheme = theme.colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _StatusPill(theme: theme, icon: Icons.route, label: 'Trip in progress'),

      const SizedBox(height: 16),

      if (rideDetails?.dropoffAddress != null)
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                rideDetails!.dropoffAddress!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),

      _SoftDivider(theme),

      Row(
        children: [
          if (rideDetails?.distanceKm != null)
            Row(
              children: [
                Text(
                  rideDetails!.paymentStatus,
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                ),
              ],
            ),
          const SizedBox(width: 8),
          Text(
            "Total",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Text(
            _formatNaira(rideDetails?.fareFinal ?? rideDetails?.fareEstimate),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
            foregroundColor: Colors.red,
          ),
          onPressed: () {},
          icon: const Icon(Icons.shield_outlined),
          label: const Text(
            'Safety',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  );
}

// ==================================================================
// RIDE COMPLETED
// ==================================================================

Widget _RideCompleted({
  required ThemeData theme,
  required GetRideByIdModel? rideDetails,
}) {
  final colorScheme = theme.colorScheme;
  final driver = rideDetails?.driver;

  return Column(
    children: [
      Icon(Icons.celebration_rounded, color: colorScheme.primary, size: 36),
      const SizedBox(height: 10),
      Text(
        'Ride completed',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      ),

      const SizedBox(height: 20),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total fare',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  _formatNaira(
                    rideDetails?.fareFinal ?? rideDetails?.fareEstimate,
                  ),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (rideDetails?.distanceKm != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${rideDetails!.distanceKm!.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),

      if (driver != null) ...[
        const SizedBox(height: 24),
        ProfilePicture(
          name: driver.user.fullName,
          radius: 28,
          fontsize: 22,
          img: driver.user.profilePhotoUrl ?? '',
        ),
        const SizedBox(height: 10),
        Text(
          'Rate your trip with ${driver.user.fullName}',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        _StarRow(theme: theme),
      ],

      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ],
  );
}
