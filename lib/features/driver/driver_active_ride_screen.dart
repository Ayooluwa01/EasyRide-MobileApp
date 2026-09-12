// import 'dart:async';
// import 'dart:developer' as developer;

// import 'package:easy_ride/app/api/client.dart';
// import 'package:easy_ride/app/models/get_ride_model.dart';
// import 'package:easy_ride/app/models/mapbox_location_model.dart';
// import 'package:easy_ride/app/router/route_names.dart';
// import 'package:easy_ride/app/services/get_ride_by_id.dart';
// import 'package:easy_ride/app/services/route_service.dart';
// import 'package:easy_ride/app/services/websocket.dart';
// import 'package:easy_ride/app/shared/location_provider.dart';
// import 'package:easy_ride/core/controllers/active_ride.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_profile_picture/flutter_profile_picture.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class DriverActiveRideScreen extends ConsumerStatefulWidget {
//   const DriverActiveRideScreen({super.key, required this.rideId});

//   final String rideId;

//   @override
//   ConsumerState<DriverActiveRideScreen> createState() =>
//       _DriverActiveRideScreenState();
// }

// class _DriverActiveRideScreenState
//     extends ConsumerState<DriverActiveRideScreen> {
//   // Google Maps controller.
//   GoogleMapController? _mapController;
//   // Currently displayed road polylines.
//   Set<Polyline> _routePolylines = {};
//   // Driver + pickup markers.
//   final Set<Marker> _markers = {};
//   LatLng? _lastRouteOrigin;
//   List<LatLng> _RotePoints = [];
//   late final Websocket _socket;

//   // Prevent multiple route requests from running at the
//   // same time.
//   bool _isFetchingRoute = false;
//   // Minimum distance the driver needs to move before
//   // requesting another route.
//   static const double _rerouteDistanceMeters = 50;
//   static const LatLng _defaultLocation = LatLng(6.5244, 3.3792);

//   @override
//   void initState() {
//     super.initState();
//     _socket = ref.read(websocketProvider);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getRideidetails();
//     });
//   }

//   // ============================================================
//   // INITIAL RIDE SETUP
//   // ============================================================

//   Future<void> getRideidetails() async {
//     final activeRide = ref.read(activeRideProvider.notifier);
//     activeRide.setRide({'id': widget.rideId, 'rideId': widget.rideId});
//     activeRide.joinRide(widget.rideId);
//     await ref.read(getRideByIdProvider.notifier).fetchRide(widget.rideId);
//     final rideState = ref.read(getRideByIdProvider);
//     final ride = rideState.valueOrNull;

//     if (ride == null) {
//       developer.log('Ride not found', name: 'ActiveRide');
//       return;
//     }

//     activeRide.setRide({
//       'id': ride.id,
//       'rideId': ride.id,
//       'status': ride.status,
//       'driverLocation': ride.driverLocation != null
//           ? {
//               'latitude': ride.driverLocation!.latitude,
//               'longitude': ride.driverLocation!.longitude,
//               'heading': ride.driverLocation!.heading,
//               'speed': ride.driverLocation!.speed,
//               'accuracy': ride.driverLocation!.accuracy,
//             }
//           : null,
//     });

//     _setRideMarkers(ride);
//     await _fetchRoadRoute(ride);
//   }

//   // ============================================================
//   // INITIAL MARKERS
//   // ============================================================

//   void _setRideMarkers(dynamic ride) {
//     final driverLocation = ride.driverLocation;
//     final destination = ride.status == 'IN_PROGRESS'
//         ? ride.dropoffLocation
//         : ride.pickupLocation;
//     // ignore: no_leading_underscores_for_local_identifiers
//     String _title = ride.status == 'IN_PROGRESS'
//         ? 'Destination'
//         : 'Pickup Location';
//     String _Snippert = ride.status == 'IN_PROGRESS'
//         ? "Rider Pickup"
//         : 'Destination Location';

//     if (driverLocation == null || destination == null) {
//       return;
//     }

//     final driverPosition = LatLng(
//       driverLocation.latitude,
//       driverLocation.longitude,
//     );

//     final destinationPosition = LatLng(
//       destination.latitude,
//       destination.longitude,
//     );

//     if (!mounted) {
//       return;
//     }
//     _lastRouteOrigin = driverPosition;

//     setState(() {
//       _markers
//         ..clear()
//         // DRIVER MARKER
//         ..add(
//           Marker(
//             markerId: const MarkerId('driver'),
//             position: driverPosition,
//             infoWindow: const InfoWindow(
//               title: 'Your Location',
//               snippet: 'Driver',
//             ),
//           ),
//         )
//         // PICKUP MARKER
//         ..add(
//           Marker(
//             markerId: const MarkerId('pickup'),
//             position: destinationPosition,
//             infoWindow: InfoWindow(title: _title, snippet: _Snippert),
//           ),
//         );
//     });
//   }

//   // ============================================================
//   // WEBSOCKET DRIVER LOCATION HANDLER
//   // ============================================================

//   void _handleDriverLocationUpdate(Map<String, dynamic>? ride) {
//     if (ride == null) {
//       return;
//     }
//     final driverLocation = ride['driverLocation'];
//     if (driverLocation == null) {
//       return;
//     }

//     final latitude = driverLocation['latitude'];
//     final longitude = driverLocation['longitude'];

//     if (latitude == null || longitude == null) {
//       developer.log('Invalid driver location received', name: 'Map');
//       return;
//     }

//     final position = LatLng(
//       (latitude as num).toDouble(),
//       (longitude as num).toDouble(),
//     );
//     _mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: position, zoom: 16),
//       ),
//     );

//     _updateDriverMarker(position);
//     _checkIfRerouteIsNeeded(position);
//   }

//   // ============================================================
//   // UPDATE DRIVER MARKER
//   // ============================================================

//   void _updateDriverMarker(LatLng position) {
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _markers.removeWhere((marker) => marker.markerId.value == 'driver');
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('driver'),
//           position: position,
//           infoWindow: const InfoWindow(
//             title: 'Your Location',
//             snippet: 'Driver',
//           ),
//         ),
//       );
//     });
//   }

//   void _updatePickuptoDesinationMarker(LatLng Position) {
//     if (!mounted) {
//       return;
//     }
//     setState(() {
//       _markers.removeWhere((marker) => marker.markerId.value == 'pickup');
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('Dropoff'),
//           position: Position,
//           infoWindow: const InfoWindow(
//             title: 'Destination',
//             snippet: 'Destination',
//           ),
//         ),
//       );
//     });
//   }

//   // ============================================================
//   // CHECK WHETHER WE NEED TO RECALCULATE THE ROUTE
//   // ============================================================

//   void _checkIfRerouteIsNeeded(LatLng currentPosition) {
//     if (_lastRouteOrigin == null) {
//       _lastRouteOrigin = currentPosition;
//       return;
//     }

//     final distance = Geolocator.distanceBetween(
//       _lastRouteOrigin!.latitude,
//       _lastRouteOrigin!.longitude,
//       currentPosition.latitude,
//       currentPosition.longitude,
//     );

//     final position = LatLng(
//       currentPosition.latitude,
//       currentPosition.longitude,
//     );
//     if (distance < _rerouteDistanceMeters) {
//       _updateDriverMarker(position);
//       return;
//     }

//     // Update the route origin immediately.
//     _lastRouteOrigin = currentPosition;

//     // Request the new route.
//     _rerouteFromCurrentLocation(currentPosition);
//   }

//   // ============================================================
//   // RECALCULATE ROUTE
//   // ============================================================

//   Future<void> _rerouteFromCurrentLocation(LatLng driverPosition) async {
//     if (_isFetchingRoute) {
//       return;
//     }

//     _isFetchingRoute = true;

//     try {
//       final ride = ref.read(getRideByIdProvider).valueOrNull;
//       developer.log('$ride');
//       if (ride == null) {
//         return;
//       }
//       final destination = ride.status == 'IN_PROGRESS'
//           ? ride.dropoffLocation
//           : ride.pickupLocation;

//       if (destination == null) {
//         developer.log('Cannot reroute: destination is null', name: 'Route');
//         return;
//       }

//       final request = GetRouteRequest(
//         originLng: driverPosition.longitude,
//         originLat: driverPosition.latitude,
//         destLng: destination.longitude,
//         destLat: destination.latitude,
//       );

//       final response = await ref.read(routeServiceProvider).getRoute(request);
//       final route = response.data;
//       final decoded = PolylinePoints.decodePolyline(route.polyline);

//       if (decoded.isEmpty) {
//         developer.log('New route decoded to 0 points', name: 'Route');
//         return;
//       }

//       final points = decoded
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList(growable: false);

//       developer.log('points,$points');

//       if (!mounted) {
//         return;
//       }

//       setState(() {
//         _routePolylines = {
//           Polyline(
//             polylineId: const PolylineId('driver-rider-route'),
//             points: points,
//             color: Colors.blue,
//             width: 5,
//             jointType: JointType.round,
//             startCap: Cap.roundCap,
//             endCap: Cap.roundCap,
//           ),
//         };
//       });

//       developer.log('Road polyline updated', name: 'Route');
//     } catch (e, stackTrace) {
//       developer.log(
//         'Failed to recalculate route',
//         name: 'Route',
//         error: e,
//         stackTrace: stackTrace,
//       );
//     } finally {
//       _isFetchingRoute = false;
//     }
//   }

//   // ============================================================
//   // INITIAL ROAD ROUTE
//   // ============================================================

//   Future<void> _fetchRoadRoute(dynamic ride) async {
//     try {
//       final driverLocation = ride.driverLocation;

//       final driverPosition = LatLng(
//         driverLocation.latitude,
//         driverLocation.longitude,
//       );

//       final destination = ride.status == 'IN_PROGRESS'
//           ? ride.dropoffLocation
//           : ride.pickupLocation;

//       if (destination == null) {
//         developer.log('Cannot fetch route: destination is null', name: 'Route');
//         return;
//       }

//       _lastRouteOrigin = driverPosition;

//       final request = GetRouteRequest(
//         originLng: driverLocation.longitude,
//         originLat: driverLocation.latitude,
//         destLng: destination.longitude,
//         destLat: destination.latitude,
//       );
//       _lastRouteOrigin = driverPosition;

//       final response = await ref.read(routeServiceProvider).getRoute(request);
//       final route = response.data;
//       final decoded = PolylinePoints.decodePolyline(route.polyline);

//       if (decoded.isEmpty) {
//         developer.log('Route polyline decoded to 0 points', name: 'Route');
//         return;
//       }

//       final points = decoded
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList(growable: false);

//       if (!mounted) {
//         return;
//       }
//       _RotePoints = points;
//       // _moveDriver();
//       setState(() {
//         _routePolylines = {
//           Polyline(
//             polylineId: const PolylineId('driver-rider-route'),
//             points: points,
//             color: Colors.blue,
//             width: 5,
//             jointType: JointType.round,
//             startCap: Cap.roundCap,
//             endCap: Cap.roundCap,
//           ),
//         };
//       });
//     } catch (e, stackTrace) {
//       developer.log(
//         'Failed to fetch road route',
//         name: 'Route',
//         error: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   // ============================================================
//   // DRIVER SIMULATION
//   // ============================================================

//   void _moveDriver() async {
//     Timer? timer;
//     for (int i = 0; i < _RotePoints.length; i++) {
//       final point = _RotePoints[i];
//       developer.log("ROUTE POINTS $point");
//       final completer = Completer<void>();
//       timer?.cancel();
//       timer = Timer(const Duration(seconds: 5), () {
//         _socket.emit('driver:location', {
//           'lat': point.latitude,
//           'lng': point.longitude,
//         });
//         completer.complete();
//       });
//       await completer.future;
//     }
//   }

//   void _markArrived() {
//     _socket.emit('ride:driver-arrived', {'rideId': widget.rideId});
//   }

//   Future<void> _startTrip() async {
//     try {
//       final response = await ref
//           .read(apiClientProvider)
//           .post('/rides/${widget.rideId}/start');

//       developer.log(
//         'START RIDE RESPONSE: ${response.data}',
//         name: 'ActiveRide',
//       );

//       final data = response.data['data'];

//       final status = data['status'] as String?;

//       if (status != 'IN_PROGRESS') {
//         developer.log(
//           'Unexpected start ride status: $status',
//           name: 'ActiveRide',
//         );
//         return;
//       }

//       // Update ActiveRide
//       ref.read(activeRideProvider.notifier).setRide({
//         'id': widget.rideId,
//         'rideId': widget.rideId,
//         'status': 'IN_PROGRESS',
//       });

//       // Refresh ride details
//       ref.invalidate(getRideByIdProvider);
//       await ref.read(getRideByIdProvider.future);
//       final ride = ref.read(getRideByIdProvider).valueOrNull;
//       if (ride == null) {
//         developer.log(
//           'Ride unavailable after starting trip',
//           name: 'ActiveRide',
//         );
//         return;
//       }
//       await _fetchRoadRoute(ride);
//       _moveDriver();
//     } catch (e, stackTrace) {
//       developer.log(
//         'START RIDE ERROR: $e',
//         name: 'ActiveRide',
//         error: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   void _cancelRide() {
//     _socket.emit('ride:cancel', {
//       'rideId': widget.rideId,
//       'cancelledBy': 'DRIVER',
//     });
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     ref.listen<Map<String, dynamic>?>(activeRideProvider, (previous, next) {
//       _handleDriverLocationUpdate(next);
//     });
//     final activeRide = ref.watch(activeRideProvider);
//     final rideStatus = activeRide?['status'] as String? ?? 'MATCHED';
//     final rideDetails = ref.watch(getRideByIdProvider).valueOrNull;
//     final userLatLng = ref.watch(userLatLngProvider);
//     final cameraTarget = userLatLng != null
//         ? LatLng(userLatLng.latitude, userLatLng.longitude)
//         : _defaultLocation;

//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: cameraTarget,
//               zoom: 14,
//             ),
//             markers: _markers,
//             polylines: _routePolylines,
//             onMapCreated: (controller) {
//               _mapController = controller;
//               developer.log('Google Map controller initialized', name: 'Map');
//             },
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             zoomControlsEnabled: false,
//           ),
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: _PickupStatusPanel(
//               status: rideStatus,
//               rideDetails: rideDetails,
//               onArrived: _markArrived,
//               onStartTrip: _startTrip,
//               onCancel: _cancelRide,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ============================================================
// //  driver's view while heading to rider
// // ============================================================

// class _PickupStatusPanel extends StatelessWidget {
//   const _PickupStatusPanel({
//     required this.status,
//     required this.rideDetails,
//     required this.onArrived,
//     required this.onStartTrip,
//     required this.onCancel,
//   });

//   final String status;
//   final GetRideByIdModel? rideDetails;
//   final VoidCallback onArrived;
//   final VoidCallback onStartTrip;
//   final VoidCallback onCancel;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final rider = rideDetails?.rider.user;

//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
//       decoration: BoxDecoration(
//         color: theme.scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 16,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Drag handle
//           Container(
//             width: 36,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 16),
//             decoration: BoxDecoration(
//               color: colorScheme.onSurface.withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           Row(
//             children: [
//               _StatusPill(
//                 theme: theme,
//                 icon: _statusIcon(status),
//                 label: _statusLabel(status),
//                 color: _statusColor(status),
//               ),
//               const Spacer(),
//             ],
//           ),

//           const SizedBox(height: 18),

//           Row(
//             children: [
//               _AvatarWithDot(
//                 name: rider?.fullName ?? 'Rider',
//                 imageUrl: rider?.profilePhotoUrl,
//                 dotColor: const Color(0xFF22C55E),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       rider?.fullName ?? 'Rider',
//                       style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on_outlined,
//                           size: 14,
//                           color: colorScheme.onSurface.withValues(alpha: 0.5),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             rideDetails?.pickupAddress ?? 'Pickup location',
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: colorScheme.onSurface.withValues(
//                                 alpha: 0.6,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               _RoundIconAction(
//                 theme: theme,
//                 icon: Icons.call,
//                 onPressed: () {},
//               ),
//               const SizedBox(width: 8),
//               _RoundIconAction(
//                 theme: theme,
//                 icon: Icons.chat_bubble_outline,
//                 onPressed: () {
//                   context.push(RouteNames.chatscreen, extra: rideDetails?.id);
//                 },
//               ),
//             ],
//           ),

//           _SoftDivider(theme),

//           SizedBox(
//             width: double.infinity,
//             child: _buildPrimaryAction(theme, colorScheme),
//           ),

//           if (status == 'MATCHED' || status == 'DRIVER_SELECTED') ...[
//             const SizedBox(height: 10),
//             TextButton(
//               onPressed: onCancel,
//               style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
//               child: const Text('Cancel Ride'),
//             ),
//           ],
//           if (status == 'DESTINATION_REACHED') ...[
//             _buildPrimaryAction(theme, colorScheme),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildPrimaryAction(ThemeData theme, ColorScheme colorScheme) {
//     switch (status) {
//       case 'MATCHED':
//       case 'DRIVER_SELECTED':
//         return ElevatedButton.icon(
//           onPressed: onArrived,
//           icon: const Icon(Icons.pin_drop_outlined),
//           label: const Text("I've Arrived"),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//         );

//       case 'DRIVER_ARRIVED':
//         return ElevatedButton.icon(
//           onPressed: onStartTrip,
//           icon: const Icon(Icons.play_arrow_rounded),
//           label: const Text('Start Trip'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF22C55E),
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//         );

//       case 'IN_PROGRESS':
//         return OutlinedButton.icon(
//           onPressed: null,
//           icon: const Icon(Icons.navigation_outlined),
//           label: const Text('Trip in progress'),
//           style: OutlinedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//         );

//       case 'DESTINATION_REACHED':

//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   IconData _statusIcon(String status) {
//     switch (status) {
//       case 'MATCHED':
//         return Icons.location_on;
//       case 'DRIVER_SELECTED':
//         return Icons.directions_car_filled;
//       case 'DRIVER_ARRIVED':
//         return Icons.location_on;
//       case 'IN_PROGRESS':
//         return Icons.navigation;
//       default:
//         return Icons.info_outline;
//     }
//   }

//   String _statusLabel(String status) {
//     switch (status) {
//       case 'MATCHED':
//         return 'Enroute Pickup';
//       case 'DRIVER_SELECTED':
//         return 'Heading to pickup';
//       case 'DRIVER_ARRIVED':
//         return "You've arrived";
//       case 'IN_PROGRESS':
//         return 'Trip in progress';
//       default:
//         return status;
//     }
//   }

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'DRIVER_ARRIVED':
//         return const Color(0xFF22C55E);
//       case 'IN_PROGRESS':
//         return const Color(0xFF3B82F6);
//       default:
//         return const Color(0xFFF59E0B);
//     }
//   }
// }

// // ============================================================
// // SHARED SMALL WIDGETS
// // ============================================================

// Widget _StatusPill({
//   required ThemeData theme,
//   required String label,
//   required IconData icon,
//   Color? color,
// }) {
//   final accent = color ?? theme.colorScheme.primary;

//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//     decoration: BoxDecoration(
//       color: accent.withValues(alpha: 0.12),
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14, color: accent),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: accent,
//             letterSpacing: 0.2,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _AvatarWithDot({
//   required String name,
//   required String? imageUrl,
//   required Color dotColor,
//   double radius = 26,
// }) {
//   return Stack(
//     clipBehavior: Clip.none,
//     children: [
//       ProfilePicture(
//         name: name,
//         radius: radius,
//         fontsize: radius - 4,
//         img: imageUrl ?? '',
//       ),
//       Positioned(
//         right: -1,
//         bottom: -1,
//         child: Container(
//           width: 14,
//           height: 14,
//           decoration: BoxDecoration(
//             color: dotColor,
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 2),
//           ),
//         ),
//       ),
//     ],
//   );
// }

// Widget _RoundIconAction({
//   required ThemeData theme,
//   required IconData icon,
//   required VoidCallback onPressed,
// }) {
//   return Material(
//     color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
//     shape: const CircleBorder(),
//     child: InkWell(
//       customBorder: const CircleBorder(),
//       onTap: onPressed,
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
//       ),
//     ),
//   );
// }

// Widget _SoftDivider(ThemeData theme) {
//   return Divider(
//     height: 28,
//     thickness: 1,
//     color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
//   );
// }

import 'dart:async';
import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/models/get_ride_model.dart';
import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/get_ride_by_id.dart';
import 'package:easy_ride/app/services/route_service.dart';
import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:easy_ride/core/controllers/active_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

String formatFare(num value) {
  final formatter = NumberFormat('#,##0', 'en_NG');
  return '₦${formatter.format(value)}';
}

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
  List<LatLng> _routePoints = [];
  late final Websocket _socket;

  // Prevent multiple route requests from running at the
  // same time.
  bool _isFetchingRoute = false;
  // Guards against double-tapping "Ride Completed" / "Start Trip".
  bool _isCompletingRide = false;
  bool _isStartingTrip = false;
  // Minimum distance the driver needs to move before
  // requesting another route.
  static const double _rerouteDistanceMeters = 50;
  static const LatLng _defaultLocation = LatLng(6.5244, 3.3792);

  // Tracks the simulation timer so it can be cancelled on dispose.
  Timer? _simulationTimer;

  // ============================================================
  // BOTTOM SHEET
  // Collapsed shows just the drag handle + status pill so the map
  // stays visible; expanded shows rider info, trip details and the
  // primary action. Draggable by hand, or toggle via the chevron.
  // ============================================================
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  static const double _sheetMinSize = 0.16;
  static const double _sheetMaxSize = 0.52;
  bool _isSheetExpanded = false;

  @override
  void initState() {
    super.initState();
    _socket = ref.read(websocketProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRideidetails();
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheet() {
    final target = _isSheetExpanded ? _sheetMinSize : _sheetMaxSize;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // INITIAL RIDE SETUP
  // ============================================================

  Future<void> getRideidetails() async {
    final activeRide = ref.read(activeRideProvider.notifier);
    activeRide.setRide({'id': widget.rideId, 'rideId': widget.rideId});
    activeRide.joinRide(widget.rideId);
    await ref.read(getRideByIdProvider.notifier).fetchRide(widget.rideId);
    final rideState = ref.read(getRideByIdProvider);
    final ride = rideState.valueOrNull;

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

    _setRideMarkers(ride);
    await _fetchRoadRoute(ride);
  }

  // ============================================================
  // INITIAL MARKERS
  // ============================================================

  void _setRideMarkers(dynamic ride) {
    final driverLocation = ride.driverLocation;
    final destination = ride.status == 'IN_PROGRESS'
        ? ride.dropoffLocation
        : ride.pickupLocation;
    final title = ride.status == 'IN_PROGRESS'
        ? 'Destination'
        : 'Pickup Location';
    final snippet = ride.status == 'IN_PROGRESS'
        ? 'Rider Pickup'
        : 'Destination Location';

    if (driverLocation == null || destination == null) {
      return;
    }

    final driverPosition = LatLng(
      driverLocation.latitude,
      driverLocation.longitude,
    );

    final destinationPosition = LatLng(
      destination.latitude,
      destination.longitude,
    );

    if (!mounted) {
      return;
    }
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
        // PICKUP / DESTINATION MARKER
        ..add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: destinationPosition,
            infoWindow: InfoWindow(title: title, snippet: snippet),
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
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );

    _updateDriverMarker(position);
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
      _markers.removeWhere((marker) => marker.markerId.value == 'driver');
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
  }

  // ============================================================
  // CHECK WHETHER WE NEED TO RECALCULATE THE ROUTE
  // ============================================================

  void _checkIfRerouteIsNeeded(LatLng currentPosition) {
    if (_lastRouteOrigin == null) {
      _lastRouteOrigin = currentPosition;
      return;
    }

    final distance = Geolocator.distanceBetween(
      _lastRouteOrigin!.latitude,
      _lastRouteOrigin!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (distance < _rerouteDistanceMeters) {
      _updateDriverMarker(currentPosition);
      return;
    }

    // Update the route origin immediately.
    _lastRouteOrigin = currentPosition;

    // Request the new route.
    _rerouteFromCurrentLocation(currentPosition);
  }

  // ============================================================
  // RECALCULATE ROUTE
  // ============================================================

  Future<void> _rerouteFromCurrentLocation(LatLng driverPosition) async {
    if (_isFetchingRoute) {
      return;
    }

    _isFetchingRoute = true;

    try {
      final ride = ref.read(getRideByIdProvider).valueOrNull;
      if (ride == null) {
        return;
      }
      final destination = ride.status == 'IN_PROGRESS'
          ? ride.dropoffLocation
          : ride.pickupLocation;

      if (destination == null) {
        developer.log('Cannot reroute: destination is null', name: 'Route');
        return;
      }

      final request = GetRouteRequest(
        originLng: driverPosition.longitude,
        originLat: driverPosition.latitude,
        destLng: destination.longitude,
        destLat: destination.latitude,
      );

      final points = await _fetchDecodedPolyline(request);
      if (points == null || !mounted) {
        return;
      }

      setState(() {
        _routePolylines = _buildRoutePolyline(points);
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
      _isFetchingRoute = false;
    }
  }

  // ============================================================
  // INITIAL ROAD ROUTE
  // ============================================================
  Future<void> _fetchRoadRoute(dynamic ride) async {
    try {
      final driverLocation = ride.driverLocation;
      if (driverLocation == null) {
        developer.log(
          'Cannot fetch route: driver location is null',
          name: 'Route',
        );
        return;
      }

      final driverPosition = LatLng(
        driverLocation.latitude,
        driverLocation.longitude,
      );

      final destination = ride.status == 'IN_PROGRESS'
          ? ride.dropoffLocation
          : ride.pickupLocation;

      developer.log('DESTINATION:${destination.longitude}');
      if (destination == null) {
        developer.log('Cannot fetch route: destination is null', name: 'Route');
        return;
      }

      _lastRouteOrigin = driverPosition;

      final request = GetRouteRequest(
        originLng: driverLocation.longitude,
        originLat: driverLocation.latitude,
        destLng: destination.longitude,
        destLat: destination.latitude,
      );

      final points = await _fetchDecodedPolyline(request);
      if (points == null || !mounted) {
        return;
      }

      _routePoints = points;
      setState(() {
        _routePolylines = _buildRoutePolyline(points);
      });
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch road route',
        name: 'Route',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Shared helper — fetches a route and decodes it into map points.
  // Used by both the initial route fetch and the rerouting logic so the
  // two no longer duplicate the same request/decode/log sequence.
  Future<List<LatLng>?> _fetchDecodedPolyline(GetRouteRequest request) async {
    final response = await ref.read(routeServiceProvider).getRoute(request);
    final route = response.data;
    final decoded = PolylinePoints.decodePolyline(route.polyline);

    if (decoded.isEmpty) {
      developer.log('Route polyline decoded to 0 points', name: 'Route');
      return null;
    }

    return decoded
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
  }

  Set<Polyline> _buildRoutePolyline(List<LatLng> points) {
    return {
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
  }

  // ============================================================
  // DRIVER SIMULATION
  // ============================================================

  void _moveDriver() async {
    for (int i = 0; i < _routePoints.length; i++) {
      if (!mounted) {
        return;
      }
      final point = _routePoints[i];
      developer.log('ROUTE POINTS $point');
      final completer = Completer<void>();
      _simulationTimer?.cancel();
      _simulationTimer = Timer(const Duration(seconds: 5), () {
        _socket.emit('driver:location', {
          'lat': point.latitude,
          'lng': point.longitude,
        });
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;
    }
  }

  void _markArrived() {
    // _socket.emit('ride:driver-arrived', {'rideId': widget.rideId});
  }

  Future<void> _startTrip() async {
    if (_isStartingTrip) {
      return;
    }
    setState(() => _isStartingTrip = true);

    try {
      final response = await ref
          .read(apiClientProvider)
          .post('/rides/${widget.rideId}/start');

      developer.log(
        'START RIDE RESPONSE: ${response.data}',
        name: 'ActiveRide',
      );

      final data = response.data['data'];
      final status = data['status'] as String?;

      if (status != 'IN_PROGRESS') {
        developer.log(
          'Unexpected start ride status: $status',
          name: 'ActiveRide',
        );
        _showError('Could not start the trip. Please try again.');
        return;
      }

      // Update ActiveRide
      ref.read(activeRideProvider.notifier).setRide({
        'id': widget.rideId,
        'rideId': widget.rideId,
        'status': 'IN_PROGRESS',
      });

      // Refresh ride details
      ref.invalidate(getRideByIdProvider);
      await ref.read(getRideByIdProvider.future);
      final ride = ref.read(getRideByIdProvider).valueOrNull;

      await _fetchRoadRoute(ride);
      _moveDriver();
    } catch (e, stackTrace) {
      _showError('Could not start the trip. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isStartingTrip = false);
      }
    }
  }

  // ============================================================
  // RIDE COMPLETED
  // ============================================================

  Future<void> _completeRide() async {
    if (_isCompletingRide) {
      return;
    }
    setState(() => _isCompletingRide = true);

    try {
      final response = await ref
          .read(apiClientProvider)
          .post('/rides/${widget.rideId}/complete');

      developer.log(
        'COMPLETE RIDE RESPONSE: ${response.data}',
        name: 'ActiveRide',
      );

      final data = response.data['data'];
      final status = data['status'] as String?;

      if (status != 'COMPLETED') {
        _showError('Could not complete the ride. Please try again.');
        return;
      }

      _simulationTimer?.cancel();
      // _socket.emit('ride:complete', {'rideId': widget.rideId});

      ref.read(activeRideProvider.notifier).setRide({
        'id': widget.rideId,
        'rideId': widget.rideId,
        'status': 'COMPLETED',
      });

      if (!mounted) {
        return;
      }
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.driverrides);
      }
    } catch (e, stackTrace) {
      developer.log(
        'COMPLETE RIDE ERROR: $e',
        name: 'ActiveRide',
        error: e,
        stackTrace: stackTrace,
      );
      _showError('Could not complete the ride. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isCompletingRide = false);
      }
    }
  }

  void _cancelRide() {
    // _socket.emit('ride:cancel', {
    //   'rideId': widget.rideId,
    //   'cancelledBy': 'DRIVER',
    // });
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, dynamic>?>(activeRideProvider, (previous, next) {
      final prevstatus = previous?['status'];
      final currentstatus = next?['status'];

      _handleDriverLocationUpdate(next);
      if (currentstatus == 'DRIVER_ARRIVED' ||
          currentstatus == 'DESTINATION_REACHED') {
        if (!_isSheetExpanded) {
          _toggleSheet();
        }
      }
    });

    final activeRide = ref.watch(activeRideProvider);
    final rideStatus = activeRide?['status'] as String? ?? 'MATCHED';
    final rideDetails = ref.watch(getRideByIdProvider).valueOrNull;
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
            markers: _markers,
            polylines: _routePolylines,
            onMapCreated: (controller) {
              _mapController = controller;
              developer.log('Google Map controller initialized', name: 'Map');
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            // Leave room to tap/pan the map above the collapsed sheet.
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * _sheetMinSize,
            ),
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              final expanded =
                  notification.extent > (_sheetMinSize + _sheetMaxSize) / 2;
              if (expanded != _isSheetExpanded) {
                setState(() => _isSheetExpanded = expanded);
              }
              return true;
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: _sheetMinSize,
              minChildSize: _sheetMinSize,
              maxChildSize: _sheetMaxSize,
              snap: true,
              snapSizes: const [_sheetMinSize, _sheetMaxSize],
              builder: (context, scrollController) {
                return _PickupStatusPanel(
                  status: rideStatus,
                  rideDetails: rideDetails,
                  isStartingTrip: _isStartingTrip,
                  isCompletingRide: _isCompletingRide,
                  isExpanded: _isSheetExpanded,
                  scrollController: scrollController,
                  onArrived: _markArrived,
                  onStartTrip: _startTrip,
                  onCancel: _cancelRide,
                  onRideCompleted: _completeRide,
                  onToggleExpanded: _toggleSheet,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  driver's view while heading to rider — bottom sheet content.
// Collapsed (min size) shows the drag handle + status pill only,
// so the map stays visible. Drag up, or tap the handle/chevron,
// to reveal rider info, trip details and the primary action.
// ============================================================

class _PickupStatusPanel extends StatelessWidget {
  const _PickupStatusPanel({
    required this.status,
    required this.rideDetails,
    required this.onArrived,
    required this.onStartTrip,
    required this.onCancel,
    required this.onRideCompleted,
    required this.onToggleExpanded,
    required this.scrollController,
    this.isStartingTrip = false,
    this.isCompletingRide = false,
    this.isExpanded = false,
  });

  final String status;
  final GetRideByIdModel? rideDetails;
  final VoidCallback onArrived;
  final VoidCallback onStartTrip;
  final VoidCallback onCancel;
  final VoidCallback onRideCompleted;
  final VoidCallback onToggleExpanded;
  final ScrollController scrollController;
  final bool isStartingTrip;
  final bool isCompletingRide;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rider = rideDetails?.rider.user;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggleExpanded,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      _StatusPill(
                        theme: theme,
                        icon: _statusIcon(status),
                        label: _statusLabel(status),
                        color: _statusColor(status),
                      ),
                      const Spacer(),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                _AvatarWithDot(
                  name: rider?.fullName ?? 'Rider',
                  imageUrl: rider?.profilePhotoUrl,
                  dotColor: const Color(0xFF22C55E),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rider?.fullName ?? 'Rider',
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
                            Icons.location_on_outlined,
                            size: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              rideDetails?.pickupAddress ?? 'Pickup location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RoundIconAction(
                  theme: theme,
                  icon: Icons.call,
                  onPressed: () {},
                ),
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

            const SizedBox(height: 14),

            _TripInfoCard(
              theme: theme,
              colorScheme: colorScheme,
              rideDetails: rideDetails,
            ),

            _SoftDivider(theme),

            SizedBox(
              width: double.infinity,
              child: _buildPrimaryAction(theme, colorScheme),
            ),

            if (status == 'MATCHED' || status == 'DRIVER_SELECTED') ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Cancel Ride'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryAction(ThemeData theme, ColorScheme colorScheme) {
    switch (status) {
      case 'MATCHED':
      case 'DRIVER_SELECTED':
        return ElevatedButton.icon(
          onPressed: onArrived,
          icon: const Icon(Icons.pin_drop_outlined),
          label: const Text("I've Arrived"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      case 'DRIVER_ARRIVED':
        return ElevatedButton.icon(
          onPressed: isStartingTrip ? null : onStartTrip,
          icon: isStartingTrip
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: Text(isStartingTrip ? 'Starting…' : 'Start Trip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      case 'IN_PROGRESS':
        return OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.navigation_outlined),
          label: const Text('Trip in progress'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      case 'DESTINATION_REACHED':
        return ElevatedButton.icon(
          onPressed: isCompletingRide ? null : onRideCompleted,
          icon: isCompletingRide
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(isCompletingRide ? 'Completing…' : 'Ride Completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'MATCHED':
        return Icons.location_on;
      case 'DRIVER_SELECTED':
        return Icons.directions_car_filled;
      case 'DRIVER_ARRIVED':
        return Icons.location_on;
      case 'IN_PROGRESS':
        return Icons.navigation;
      case 'DESTINATION_REACHED':
        return Icons.flag_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'MATCHED':
        return 'Enroute Pickup';
      case 'DRIVER_SELECTED':
        return 'Heading to pickup';
      case 'DRIVER_ARRIVED':
        return "You've arrived";
      case 'IN_PROGRESS':
        return 'Trip in progress';
      case 'DESTINATION_REACHED':
        return 'Destination reached';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'DRIVER_ARRIVED':
        return const Color(0xFF22C55E);
      case 'IN_PROGRESS':
        return const Color(0xFF3B82F6);
      case 'DESTINATION_REACHED':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

// ============================================================
// TRIP INFO CARD — fare, payment, distance and the pickup/dropoff
// route, visible through every stage of the journey.
// ============================================================

Widget _TripInfoCard({
  required ThemeData theme,
  required ColorScheme colorScheme,
  required GetRideByIdModel? rideDetails,
}) {
  final fareAmount = rideDetails?.fareFinal ?? rideDetails?.fareEstimate;
  final paymentMethod = rideDetails?.paymentMethod;
  final paymentStatus = rideDetails?.paymentStatus;
  final distanceKm = rideDetails?.distanceKm;
  final pickupAddress = rideDetails?.pickupAddress ?? 'Pickup location';
  final dropoffAddress = rideDetails?.dropoffAddress ?? 'Destination';

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: colorScheme.onSurface.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteRow(
          theme: theme,
          colorScheme: colorScheme,
          pickupAddress: pickupAddress,
          dropoffAddress: dropoffAddress,
        ),
        const SizedBox(height: 12),
        Divider(
          height: 1,
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TripInfoTile(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Fare',
                value: fareAmount != null ? formatFare(fareAmount) : '—',
              ),
            ),
            Expanded(
              child: _TripInfoTile(
                theme: theme,
                colorScheme: colorScheme,
                label: 'Distance',
                value: distanceKm != null
                    ? '${distanceKm.toStringAsFixed(1)} km'
                    : '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PaymentMethodChip(
              theme: theme,
              colorScheme: colorScheme,
              method: paymentMethod,
            ),
            _PaymentStatusChip(theme: theme, paymentStatus: paymentStatus),
          ],
        ),
      ],
    ),
  );
}

Widget _RouteRow({
  required ThemeData theme,
  required ColorScheme colorScheme,
  required String pickupAddress,
  required String dropoffAddress,
}) {
  final mutedText = TextStyle(
    fontSize: 13,
    color: colorScheme.onSurface.withValues(alpha: 0.85),
  );

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          Container(
            width: 1,
            height: 26,
            margin: const EdgeInsets.symmetric(vertical: 2),
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const Icon(Icons.location_on, size: 14, color: Color(0xFFEF4444)),
        ],
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pickupAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mutedText,
            ),
            const SizedBox(height: 18),
            Text(
              dropoffAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mutedText,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _TripInfoTile({
  required ThemeData theme,
  required ColorScheme colorScheme,
  required String label,
  required String value,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    ],
  );
}

Widget _PaymentMethodChip({
  required ThemeData theme,
  required ColorScheme colorScheme,
  required String? method,
}) {
  final label = _formatPaymentMethod(method);
  final icon = _paymentMethodIcon(method);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: colorScheme.onSurface.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    ),
  );
}

Widget _PaymentStatusChip({
  required ThemeData theme,
  required String? paymentStatus,
}) {
  final color = _paymentStatusColor(paymentStatus);
  final label = _formatPaymentStatus(paymentStatus);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

String _formatPaymentMethod(String? method) {
  switch (method) {
    case 'CASH':
      return 'Cash';
    case 'CARD':
      return 'Card';
    case 'WALLET':
      return 'Wallet';
    default:
      return method ?? 'Unknown';
  }
}

IconData _paymentMethodIcon(String? method) {
  switch (method) {
    case 'CASH':
      return Icons.payments_outlined;
    case 'CARD':
      return Icons.credit_card;
    case 'WALLET':
      return Icons.account_balance_wallet_outlined;
    default:
      return Icons.payment;
  }
}

String _formatPaymentStatus(String? status) {
  switch (status) {
    case 'PAID':
      return 'Paid';
    case 'PENDING':
      return 'Payment pending';
    case 'FAILED':
      return 'Payment failed';
    default:
      return status ?? 'Unknown';
  }
}

Color _paymentStatusColor(String? status) {
  switch (status) {
    case 'PAID':
      return const Color(0xFF22C55E);
    case 'FAILED':
      return const Color(0xFFEF4444);
    case 'PENDING':
    default:
      return const Color(0xFFF59E0B);
  }
}

// ============================================================
// SHARED SMALL WIDGETS
// ============================================================

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

Widget _RoundIconAction({
  required ThemeData theme,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return Material(
    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
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
