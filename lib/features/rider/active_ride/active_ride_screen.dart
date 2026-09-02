// ignore_for_file: non_constant_identifier_names

import 'dart:developer' as developer;

import 'package:easy_ride/app/models/get_ride_model.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/get_ride_by_id.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:easy_ride/app/theme/app_theme.dart';
import 'package:easy_ride/core/controllers/active_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ActiveRideScreen extends ConsumerStatefulWidget {
  final String rideId;

  const ActiveRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  // ============================================================
  // MAPBOX
  // ============================================================

  MapboxMap? _mapboxController;

  PointAnnotationManager? _pointAnnotationManager;

  PolylineAnnotationManager? _polylineAnnotationManager;

  PointAnnotation? _riderMarker;

  PointAnnotation? _driverMarker;

  PolylineAnnotation? _riderDriverLine;

  // ============================================================
  // UPDATE CONTROL
  // ============================================================

  bool _updatingMarkers = false;

  bool _mapReady = false;

  bool _disposed = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    ref.listenManual(activeRideProvider, (_, __) {
      _updateMarkers();
    });

    ref.listenManual(locationProvider, (_, __) {
      _updateMarkers();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_disposed) return;

      developer.log(
        'ActiveRideScreen initialized with rideId: ${widget.rideId}',
        name: 'ActiveRide',
      );

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

      developer.log('Initial ride loaded: ${ride.id}', name: 'ActiveRide');
    });
  }

  // ============================================================
  // UPDATE MARKERS
  // ============================================================

  Future<void> _updateMarkers() async {
    if (_disposed) return;

    if (!_mapReady) {
      return;
    }

    final pointManager = _pointAnnotationManager;

    if (pointManager == null) {
      return;
    }

    if (_updatingMarkers) {
      return;
    }

    _updatingMarkers = true;

    try {
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

      if (userPosition != null) {
        final riderPoint = Point(
          coordinates: Position(userPosition.longitude, userPosition.latitude),
        );

        if (_riderMarker == null) {
          _riderMarker = await pointManager.create(
            PointAnnotationOptions(geometry: riderPoint),
          );
        } else {
          _riderMarker!.geometry = riderPoint;

          await pointManager.update(_riderMarker!);
        }
      }

      if (driverLatitude != null && driverLongitude != null) {
        final driverPoint = Point(
          coordinates: Position(driverLongitude, driverLatitude),
        );

        if (_driverMarker == null) {
          _driverMarker = await pointManager.create(
            PointAnnotationOptions(geometry: driverPoint),
          );
        } else {
          _driverMarker!.geometry = driverPoint;

          await pointManager.update(_driverMarker!);
        }
      }

      if (userPosition != null &&
          driverLatitude != null &&
          driverLongitude != null) {
        await _updateRoute(
          riderLatitude: userPosition.latitude,
          riderLongitude: userPosition.longitude,
          driverLatitude: driverLatitude,
          driverLongitude: driverLongitude,
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to update Mapbox markers',
        name: 'ActiveRideMap',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _updatingMarkers = false;
    }
  }

  // ============================================================
  // UPDATE ROUTE
  // ============================================================

  Future<void> _updateRoute({
    required double riderLatitude,
    required double riderLongitude,
    required double driverLatitude,
    required double driverLongitude,
  }) async {
    final manager = _polylineAnnotationManager;

    if (manager == null) {
      return;
    }

    final routeCoordinates = [
      Position(riderLongitude, riderLatitude),
      Position(driverLongitude, driverLatitude),
    ];

    final lineString = LineString(coordinates: routeCoordinates);

    if (_riderDriverLine == null) {
      _riderDriverLine = await manager.create(
        PolylineAnnotationOptions(
          geometry: lineString,
          lineWidth: 5.0,
          lineColor: Colors.blue.toARGB32(),
        ),
      );
    } else {
      _riderDriverLine!.geometry = lineString;

      await manager.update(_riderDriverLine!);
    }
  }

  // ============================================================
  // MAP CREATED
  // ============================================================

  Future<void> _onMapCreated(MapboxMap controller) async {
    if (_disposed) return;

    developer.log('Mapbox map created', name: 'ActiveRideMap');

    _mapboxController = controller;

    await controller.location.updateSettings(
      LocationComponentSettings(enabled: false),
    );

    if (_disposed) return;

    _pointAnnotationManager = await controller.annotations
        .createPointAnnotationManager();

    if (_disposed) return;

    _polylineAnnotationManager = await controller.annotations
        .createPolylineAnnotationManager();

    if (_disposed) return;

    _mapReady = true;

    await _updateMarkers();

    if (_disposed) return;

    final socketRide = ref.read(activeRideProvider);

    final rideDetails = ref.read(getRideByIdProvider).valueOrNull;

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

    if (latitude != null && longitude != null) {
      await controller.easeTo(
        CameraOptions(
          center: Point(coordinates: Position(longitude, latitude)),
          zoom: 14.0,
        ),
        MapAnimationOptions(duration: 800),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

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

    developer.log(
      'Driver location: '
      '$latitude, $longitude',
      name: 'ActiveRide',
    );

    developer.log(
      'User location: '
      '${userPosition?.latitude}, '
      '${userPosition?.longitude}',
      name: 'ActiveRide',
    );

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('active_ride_map'),
            styleUri: isDark ? MapboxStyles.DARK : MapboxStyles.MAPBOX_STREETS,
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
                color: isDark ? const Color(0xFF161616) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
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
                  // Drag handle
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
    _pointAnnotationManager?.deleteAll();
    _polylineAnnotationManager?.deleteAll();
    _pointAnnotationManager = null;
    _polylineAnnotationManager = null;
    _riderMarker = null;
    _driverMarker = null;
    _riderDriverLine = null;
    _mapboxController = null;
    super.dispose();
  }
}

// ==================================================================
// SHARED HELPERS
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
      // ==========================================================
      // STATUS + ETA
      // ==========================================================
      Row(
        children: [
          _StatusPill(
            theme: theme,
            icon: Icons.directions_car_filled,
            label: 'Driver on the way',
          ),
          const Spacer(),
          // Text(
          //   '3 min', // No ETA field on the ride model yet.
          //   style: TextStyle(
          //     fontSize: 15,
          //     fontWeight: FontWeight.w800,
          //     color: colorScheme.primary,
          //   ),
          // ),
        ],
      ),

      const SizedBox(height: 18),

      // ==========================================================
      // DRIVER CARD
      // ==========================================================
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

      // ==========================================================
      // PAYMENT METHOD + AMOUNT
      // ==========================================================
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

      // ==========================================================
      // CANCEL RIDE
      // ==========================================================
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

          // Icon(
          //   _paymentMethodIcon(rideDetails?.paymentMethod),
          //   size: 18,
          //   color: colorScheme.primary,
          // ),
          const SizedBox(width: 8),
          Text(
            // _paymentMethodLabel(rideDetails?.paymentMethod),
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
