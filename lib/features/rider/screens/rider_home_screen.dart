import 'dart:async';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/services/check_active_ride.dart';
import 'package:easy_ride/app/services/user_controller.dart';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  GoogleMapController? _mapController;
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
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: zoom),
      ),
    );
  }

  Future<void> _applyMapStyle(bool isDark, ColorScheme colorScheme) async {
    final controller = _mapController;
    if (controller == null) return;

    // Google Maps styling is done via JSON map style, not a named style enum.
    // Load your dark/light style JSON strings (e.g. from assets) and apply:
    // await controller.setMapStyle(isDark ? darkStyleJson : null);

    _currentMapStyleIsDark = isDark;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final locationState = ref.watch(locationProvider);
    final userLatLng = ref.watch(userLatLngProvider);

    if (_mapController != null && _currentMapStyleIsDark != isDark) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyMapStyle(isDark, colorScheme);
      });
    }
    final data = ref.watch(currentUserProvider);
    final user = data.value;
    ref.listen(locationProvider, (previous, next) {
      next.whenData((position) {
        if (_isFollowingUser && _mapController != null) {
          _flyToLocation(position.latitude, position.longitude);
        }
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          // GOOGLE MAPS LAYER
          GoogleMap(
            key: const ValueKey("google_native_map"),
            initialCameraPosition: const CameraPosition(
              target: LatLng(_lagosLat, _lagosLng),
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) async {
              _mapController = controller;
              _currentMapStyleIsDark = isDark;
              // await controller.setMapStyle(isDark ? darkStyleJson : null);

              if (userLatLng != null) {
                _flyToLocation(userLatLng.latitude, userLatLng.longitude);
              }
            },
            onCameraMoveStarted: () {
              // Fires on any camera movement, including user drag/pinch —
              // this is the closest equivalent to Mapbox's onScrollListener.
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
                                'WELCOME, ${user?.fullName?.toUpperCase() ?? "User"}',
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
