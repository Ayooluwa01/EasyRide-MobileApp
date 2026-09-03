// import 'package:easy_ride/app/shared/location_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class RiderHomeScreen extends ConsumerStatefulWidget {
//   const RiderHomeScreen({super.key});

//   @override
//   ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
// }

// class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen>
//     with TickerProviderStateMixin {
//   final MapController _mapController = MapController();
//   MapboxMap? mapboxcontroller;
//   static const LatLng _lagosCenter = LatLng(6.5244, 3.3792);
//   bool _hasMovedToUserLocation = false;

//   void _animatedMapMove(LatLng destLocation, double destZoom) {
//     final latTween = Tween<double>(
//       begin: _mapController.camera.center.latitude,
//       end: destLocation.latitude,
//     );
//     final lngTween = Tween<double>(
//       begin: _mapController.camera.center.longitude,
//       end: destLocation.longitude,
//     );
//     final zoomTween = Tween<double>(
//       begin: _mapController.camera.zoom,
//       end: destZoom,
//     );

//     final controller = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     final Animation<double> animation = CurvedAnimation(
//       parent: controller,
//       curve: Curves.fastOutSlowIn,
//     );

//     controller.addListener(() {
//       _mapController.move(
//         LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
//         zoomTween.evaluate(animation),
//       );
//     });

//     animation.addStatusListener((status) {
//       if (status == AnimationStatus.completed ||
//           status == AnimationStatus.dismissed) {
//         controller.dispose();
//       }
//     });

//     controller.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

//     final locationState = ref.watch(locationProvider);
//     final userLatLng = ref.watch(userLatLngProvider);

//     ref.listen(locationProvider, (previous, next) {
//       next.whenData((position) {
//         if (!_hasMovedToUserLocation) {
//           _hasMovedToUserLocation = true;
//           _animatedMapMove(LatLng(position.latitude, position.longitude), 16.0);
//         }
//       });
//     });

//     final tileUrl = isDark
//         ? 'https://a.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}@2x.png'
//         : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';

//     return Scaffold(
//       // backgroundColor: colorScheme.surface,
//       body: Stack(
//         children: [
//           MapWidget(
//             onMapCreated: (controller) {
//               setState(() {
//                 mapboxcontroller = controller;
//               });
//               mapboxcontroller?.location.updateSettings(
//                 LocationComponentSettings(enabled: true, pulsingEnabled: true),
//               );
//             },
//           ),
//           // FlutterMap(
//           //   mapController: _mapController,
//           //   options: const MapOptions(
//           //     initialCenter: _lagosCenter,
//           //     initialZoom:
//           //         15.5, // Zoom level 15-16 exposes detailed street labels
//           //   ),
//           //   children: [
//           //     TileLayer(
//           //       urlTemplate: tileUrl,
//           //       userAgentPackageName: 'com.easyride.app',
//           //     ),

//           //     MarkerLayer(
//           //       markers: [
//           //         if (userLatLng != null)
//           //           Marker(
//           //             point: userLatLng,
//           //             width: 60,
//           //             height: 60,
//           //             alignment: Alignment.center,
//           //             child: Stack(
//           //               alignment: Alignment.center,
//           //               children: [
//           //                 Container(
//           //                   width: 54,
//           //                   height: 54,
//           //                   decoration: BoxDecoration(
//           //                     shape: BoxShape.circle,
//           //                     color: colorScheme.primary.withValues(
//           //                       alpha: 0.25,
//           //                     ),
//           //                     border: Border.all(
//           //                       color: colorScheme.primary.withValues(
//           //                         alpha: 0.5,
//           //                       ),
//           //                       width: 1.5,
//           //                     ),
//           //                   ),
//           //                 ),
//           //                 Container(
//           //                   width: 32,
//           //                   height: 32,
//           //                   decoration: BoxDecoration(
//           //                     shape: BoxShape.circle,
//           //                     color: isDark
//           //                         ? colorScheme.surface
//           //                         : const Color(0xFF1E1E1E),
//           //                     boxShadow: const [
//           //                       BoxShadow(
//           //                         color: Colors.black38,
//           //                         blurRadius: 8,
//           //                         offset: Offset(0, 3),
//           //                       ),
//           //                     ],
//           //                   ),
//           //                   child: Center(
//           //                     child: Container(
//           //                       width: 12,
//           //                       height: 12,
//           //                       decoration: BoxDecoration(
//           //                         color: colorScheme.primary,
//           //                         shape: BoxShape.circle,
//           //                       ),
//           //                     ),
//           //                   ),
//           //                 ),
//           //               ],
//           //             ),
//           //           ),
//           //       ],
//           //     ),
//           //   ],
//           // ),

//           // TOP SEARCH BAR
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Card(
//                 elevation: 4,
//                 color: colorScheme.surface,
//                 shadowColor: Colors.black26,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(28),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.search, color: colorScheme.onSurfaceVariant),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Where to?',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                       const Spacer(),
//                       CircleAvatar(
//                         radius: 14,
//                         backgroundColor: colorScheme.surfaceContainerHigh,
//                         child: Icon(
//                           Icons.person,
//                           size: 18,
//                           color: colorScheme.onSurface,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // FULL-SCREEN PRELOADER UNTIL GPS IS READY
//           if (locationState.isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: colorScheme.surface.withOpacity(0.85),
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: colorScheme.surface,
//                           shape: BoxShape.circle,
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 16,
//                               spreadRadius: 2,
//                             ),
//                           ],
//                         ),
//                         child: SizedBox(
//                           width: 32,
//                           height: 32,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 3,
//                             color: colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Locating your position...',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: colorScheme.onSurface,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // ANIMATED RECENTER BUTTON
//           Positioned(
//             bottom: 30,
//             right: 16,
//             child: FloatingActionButton(
//               mini: true,
//               backgroundColor: colorScheme.surface,
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(Icons.my_location, color: colorScheme.onSurface),
//               onPressed: () async {
//                 await ref.read(locationProvider.notifier).refreshLocation();
//                 final current = ref.read(userLatLngProvider);
//                 if (current != null) {
//                   _animatedMapMove(current, 16.0);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/check_active_ride.dart';
import 'package:easy_ride/app/services/user_controller.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  MapboxMap? _mapboxController;
  bool _isFollowingUser = true;
  bool? _currentMapStyleIsDark;
  static const double _lagosLat = 6.5244;
  static const double _lagosLng = 3.3792;

  // Search State
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHome();
    });
  }

  Future<void> _initializeHome() async {
    if (!mounted) return;

    await ref.read(currentUserProvider.notifier).getCurrentUser();

    try {
      final activeRide = await ref
          .read(checkActiveRideProvider)
          .checkActiveRideForRider();
      if (!mounted) return;

      if (activeRide?.id != null) {
        context.go(RouteNames.activeride, extra: activeRide?.id);
      }
    } catch (e) {
      debugPrint('Failed to check active ride: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _flyToLocation(double lat, double lng, {double zoom = 16.0}) {
    _mapboxController?.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 800),
    );
  }

  Future<void> _applyMapStyle(bool isDark, ColorScheme colorScheme) async {
    final controller = _mapboxController;
    if (controller == null) return;

    await controller.style.setStyleURI(
      isDark ? MapboxStyles.DARK : MapboxStyles.MAPBOX_STREETS,
    );

    await controller.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: colorScheme.primary.toARGB32(),
      ),
    );

    _currentMapStyleIsDark = isDark;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final locationState = ref.watch(locationProvider);
    final userLatLng = ref.watch(userLatLngProvider);

    if (_mapboxController != null && _currentMapStyleIsDark != isDark) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyMapStyle(isDark, colorScheme);
      });
    }
    final data = ref.watch(currentUserProvider);
    final user = data.value;
    ref.listen(locationProvider, (previous, next) {
      next.whenData((position) {
        if (_isFollowingUser && _mapboxController != null) {
          _flyToLocation(position.latitude, position.longitude);
        }
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          // MAPBOX LAYER
          MapWidget(
            key: const ValueKey("mapbox_native_map"),
            styleUri: isDark ? MapboxStyles.DARK : MapboxStyles.MAPBOX_STREETS,
            viewport: CameraViewportState(
              center: Point(coordinates: Position(_lagosLng, _lagosLat)),
              zoom: 14.0,
            ),
            onMapCreated: (controller) async {
              _mapboxController = controller;
              _currentMapStyleIsDark = isDark;
              await controller.location.updateSettings(
                LocationComponentSettings(
                  enabled: true,
                  pulsingEnabled: true,
                  pulsingColor: colorScheme.primary.toARGB32(),
                ),
              );

              if (userLatLng != null) {
                _flyToLocation(userLatLng.latitude, userLatLng.longitude);
              }
            },
            onScrollListener: (_) {
              if (_isFollowingUser) {
                setState(() => _isFollowingUser = false);
              }
            },
          ),

          // TOP CARDS
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Card
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    color: isDark
                        ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=32',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WELCOME, ${user?.fullName.toUpperCase() ?? ""}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'WHERE TO TODAY?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shield_outlined,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    color: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: InkWell(
                      onTap: () => context.push(RouteNames.requestride),
                      // _showWhereToBottomSheet(context, colorScheme, isDark),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                size: 28,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'QUICK ACTION',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Request a Ride',
                                    style: GoogleFonts.syne(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'TAP TO START',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // PRELOADER
          if (locationState.isLoading)
            Positioned.fill(
              child: Container(
                color: colorScheme.surface.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Locating your position...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // RECENTER FAB
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: colorScheme.surface,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.my_location,
                color: _isFollowingUser
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
              onPressed: () async {
                setState(() => _isFollowingUser = true);
                final current = ref.read(userLatLngProvider);
                if (current != null) {
                  _flyToLocation(current.latitude, current.longitude);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
