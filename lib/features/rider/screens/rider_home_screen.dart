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
import 'dart:convert';
import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  int _searchRequestId = 0;

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

  void _onSearchQueryChanged(
    String query,
    StateSetter setModalState, {
    required bool Function() isSheetOpen,
  }) {
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();
    final requestId = ++_searchRequestId;

    if (trimmedQuery.isEmpty) {
      setModalState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setModalState(() => _isSearching = true);

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final results = await _fetchMapboxGeocodingResults(trimmedQuery);
      if (mounted && isSheetOpen() && requestId == _searchRequestId) {
        setModalState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
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

  Future<List<Map<String, dynamic>>> _fetchMapboxGeocodingResults(
    String query,
  ) async {
    final token = dotenv.env['MAP_BOX_TOKEN'];
    if (token == null || token.isEmpty) return [];

    final userLatLng = ref.read(userLatLngProvider);
    final proximityLng = userLatLng?.longitude ?? _lagosLng;
    final proximityLat = userLatLng?.latitude ?? _lagosLat;

    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json'
      '?access_token=$token'
      '&proximity=$proximityLng,$proximityLat'
      '&country=NG'
      '&limit=5',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'] ?? [];
        return features.map((feature) {
          final List center = feature['center'] ?? [0.0, 0.0];
          return {
            'title': feature['text'] ?? '',
            'subtitle': feature['place_name'] ?? '',
            'lng': (center[0] as num).toDouble(),
            'lat': (center[1] as num).toDouble(),
          };
        }).toList();
      }
    } catch (e) {
      // Search suggestions are best-effort; keep the ride sheet responsive.
    }

    return [];
  }

  void _selectDestination(Map<String, dynamic> location) {
    Navigator.pop(context);
    _isFollowingUser = false;
    _flyToLocation(
      location['lat'] as double,
      location['lng'] as double,
      zoom: 15.5,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${location['title']}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWhereToBottomSheet(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    _searchController.clear();
    _searchResults.clear();
    _isSearching = false;
    _debounceTimer?.cancel();
    _searchRequestId++;
    var isSheetOpen = true;

    final titleStyle = GoogleFonts.syne(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.1,
      color: isDark ? Colors.white : Colors.black,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      requestFocus: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final maxSheetHeight = MediaQuery.of(context).size.height * 0.65;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxSheetHeight),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag Handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Title Header
                          Text('Where to\ntoday?', style: titleStyle),
                          const SizedBox(height: 6),
                          Text(
                            'Lagos is moving fast. We\'re ready.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Destination Input Field
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF242424)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: false,
                                    onChanged: (val) => _onSearchQueryChanged(
                                      val,
                                      setModalState,
                                      isSheetOpen: () => isSheetOpen,
                                    ),
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Where are you going?',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (_isSearching)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  )
                                else if (_searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      _onSearchQueryChanged(
                                        '',
                                        setModalState,
                                        isSheetOpen: () => isSheetOpen,
                                      );
                                    },
                                    child: Icon(
                                      Icons.cancel,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      size: 18,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.search,
                                    color: colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (_searchResults.isEmpty && !_isSearching)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildQuickLocationChip(
                                    icon: Icons.home_rounded,
                                    label: 'Home',
                                    isDark: isDark,
                                    colorScheme: colorScheme,
                                  ),
                                  const SizedBox(width: 10),
                                  _buildQuickLocationChip(
                                    icon: Icons.work_rounded,
                                    label: 'Work',
                                    isDark: isDark,
                                    colorScheme: colorScheme,
                                  ),
                                  const SizedBox(width: 10),
                                  _buildQuickLocationChip(
                                    icon: Icons.star_rounded,
                                    label: 'Favorites',
                                    isDark: isDark,
                                    colorScheme: colorScheme,
                                  ),
                                ],
                              ),
                            )
                          else
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _searchResults.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                                itemBuilder: (context, index) {
                                  final item = _searchResults[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item['subtitle'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black54,
                                      ),
                                    ),
                                    onTap: () => _selectDestination(item),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      isSheetOpen = false;
      _debounceTimer?.cancel();
      _searchRequestId++;
      _isSearching = false;
    });
  }

  Widget _buildQuickLocationChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.black),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
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
                                'WELCOME, AMAKA',
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
                      onTap: () =>
                          _showWhereToBottomSheet(context, colorScheme, isDark),
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
