import 'dart:async';
import 'dart:convert';

import 'package:easy_ride/app/shared/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RequestRideScreen extends ConsumerStatefulWidget {
  const RequestRideScreen({super.key});

  @override
  ConsumerState<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends ConsumerState<RequestRideScreen> {
  MapboxMap? _mapboxController;
  CircleAnnotationManager? _pickupAnnotationManager;
  CircleAnnotationManager? _destAnnotationManager;

  static const String _routeSourceId = 'route-line-source';
  static const String _routeCasingLayerId = 'route-line-casing';
  static const String _routeLineLayerId = 'route-line-layer';
  bool _hasRouteLayer = false;

  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();
  Timer? _debounceTimer;
  int _searchRequestId = 0;

  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;

  _RideDestination? _selectedDestination;
  _RouteInfo? _routeInfo;
  bool _isRoutingLoading = false;

  static const double _fallbackLat = 6.5244;
  static const double _fallbackLng = 3.3792;

  @override
  void dispose() {
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  ({double lat, double lng}) get _pickupLatLng {
    final userLatLng = ref.read(userLatLngProvider);
    return (
      lat: userLatLng?.latitude ?? _fallbackLat,
      lng: userLatLng?.longitude ?? _fallbackLng,
    );
  }

  // ---------------------------------------------------------------------
  // Map lifecycle
  // ---------------------------------------------------------------------

  Future<void> _onMapCreated(MapboxMap controller) async {
    _mapboxController = controller;

    await controller.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    _pickupAnnotationManager = await controller.annotations
        .createCircleAnnotationManager();
    _destAnnotationManager = await controller.annotations
        .createCircleAnnotationManager();

    final pickup = _pickupLatLng;
    await _drawPickupMarker(pickup.lat, pickup.lng);

    await controller.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(pickup.lng, pickup.lat)),
        zoom: 15.5,
      ),
      MapAnimationOptions(duration: 700),
    );
  }

  Future<void> _drawPickupMarker(double lat, double lng) async {
    final manager = _pickupAnnotationManager;
    if (manager == null) return;
    await manager.deleteAll();
    await manager.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        circleRadius: 7,
        circleColor: Colors.white.toARGB32(),
        circleStrokeWidth: 3,
        circleStrokeColor: const Color(0xFF1E1E1E).toARGB32(),
      ),
    );
  }

  Future<void> _drawDestinationMarker(
    double lat,
    double lng,
    Color primary,
  ) async {
    final manager = _destAnnotationManager;
    if (manager == null) return;
    await manager.deleteAll();
    await manager.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        circleRadius: 8,
        circleColor: primary.toARGB32(),
        circleStrokeWidth: 3,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );
  }

  Future<void> getLineLayer(
    List<List<double>> coordinates,
    Color primaryColor,
  ) async {
    final controller = _mapboxController;
    if (controller == null || coordinates.isEmpty) return;

    final routeGeoJson = jsonEncode({
      'type': 'Feature',
      'properties': {},
      'geometry': {'type': 'LineString', 'coordinates': coordinates},
    });

    if (!_hasRouteLayer) {
      await controller.style.addSource(
        GeoJsonSource(id: _routeSourceId, data: routeGeoJson),
      );

      await controller.style.addLayer(
        LineLayer(
          id: _routeCasingLayerId,
          sourceId: _routeSourceId,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,
          lineWidth: 9,
          lineColor: Colors.black.toARGB32(),
          lineOpacity: 0.25,
        ),
      );

      await controller.style.addLayer(
        LineLayer(
          id: _routeLineLayerId,
          sourceId: _routeSourceId,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,
          lineWidth: 5,
          lineColor: primaryColor.toARGB32(),
        ),
      );

      _hasRouteLayer = true;
    } else {
      await controller.style.setStyleSourceProperty(
        _routeSourceId,
        'data',
        routeGeoJson,
      );
    }
  }

  Future<void> _removeRouteLineLayer() async {
    final controller = _mapboxController;
    if (controller == null || !_hasRouteLayer) return;
    try {
      await controller.style.removeStyleLayer(_routeLineLayerId);
      await controller.style.removeStyleLayer(_routeCasingLayerId);
      await controller.style.removeStyleSource(_routeSourceId);
    } catch (_) {}
    _hasRouteLayer = false;
  }

  Future<void> _fitCameraToRoute({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
    required double distanceKm,
  }) async {
    final controller = _mapboxController;
    if (controller == null) return;

    final midLat = (pickupLat + destLat) / 2;
    final midLng = (pickupLng + destLng) / 2;

    double zoom;
    if (distanceKm < 1) {
      zoom = 14.5;
    } else if (distanceKm < 3) {
      zoom = 13.3;
    } else if (distanceKm < 7) {
      zoom = 12.2;
    } else if (distanceKm < 15) {
      zoom = 11;
    } else {
      zoom = 9.5;
    }

    await controller.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(midLng, midLat)),
        zoom: zoom,
        padding: MbxEdgeInsets(top: 220, left: 40, right: 40, bottom: 260),
      ),
      MapAnimationOptions(duration: 900),
    );
  }

  // ---------------------------------------------------------------------
  // Search (Mapbox Geocoding)
  // ---------------------------------------------------------------------

  void _onDestinationChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    final requestId = ++_searchRequestId;

    // Typing again after a place was picked clears the confirmed selection.
    if (_selectedDestination != null) {
      setState(() {
        _selectedDestination = null;
        _routeInfo = null;
      });
      _destAnnotationManager?.deleteAll();
      unawaited(_removeRouteLineLayer());
    }

    if (trimmed.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final results = await _fetchMapboxGeocodingResults(trimmed);
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMapboxGeocodingResults(
    String query,
  ) async {
    final token = dotenv.env['MAP_BOX_TOKEN'];
    if (token == null || token.isEmpty) return [];

    final pickup = _pickupLatLng;
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json'
      '?access_token=$token'
      '&proximity=${pickup.lng},${pickup.lat}'
      '&country=NG'
      '&limit=6',
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
    } catch (_) {
      // Best-effort suggestions; fail quietly and keep the UI responsive.
    }
    return [];
  }

  // ---------------------------------------------------------------------
  // Route (Mapbox Directions)
  // ---------------------------------------------------------------------

  Future<void> _selectSuggestion(Map<String, dynamic> place) async {
    final colorScheme = Theme.of(context).colorScheme;
    _destinationFocusNode.unfocus();
    _debounceTimer?.cancel();

    final destination = _RideDestination(
      title: place['title'] as String,
      subtitle: place['subtitle'] as String,
      lat: place['lat'] as double,
      lng: place['lng'] as double,
    );

    setState(() {
      _selectedDestination = destination;
      _suggestions = [];
      _isRoutingLoading = true;
      _routeInfo = null;
    });
    _destinationController.text = destination.title;

    await _drawDestinationMarker(
      destination.lat,
      destination.lng,
      colorScheme.primary,
    );

    final pickup = _pickupLatLng;
    final route = await _fetchDrivingRoute(
      pickup: pickup,
      destination: destination,
    );

    if (!mounted) return;
    setState(() {
      _routeInfo = route;
      _isRoutingLoading = false;
    });

    if (route != null) {
      await _fitCameraToRoute(
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        destLat: destination.lat,
        destLng: destination.lng,
        distanceKm: route.distanceMeters / 1000,
      );
      await getLineLayer(route.coordinates, colorScheme.primary);
    }
  }

  Future<_RouteInfo?> _fetchDrivingRoute({
    required ({double lat, double lng}) pickup,
    required _RideDestination destination,
  }) async {
    final token = dotenv.env['MAP_BOX_TOKEN'];
    if (token == null || token.isEmpty) return null;

    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/'
      '${pickup.lng},${pickup.lat};${destination.lng},${destination.lat}'
      '?geometries=geojson&overview=full&access_token=$token',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List routes = data['routes'] ?? [];
        if (routes.isEmpty) return null;
        final route = routes.first;
        final List coords = route['geometry']['coordinates'];
        return _RouteInfo(
          coordinates: coords
              .map<List<double>>(
                (c) => [(c[0] as num).toDouble(), (c[1] as num).toDouble()],
              )
              .toList(),
          distanceMeters: (route['distance'] as num).toDouble(),
          durationSeconds: (route['duration'] as num).toDouble(),
        );
      }
    } catch (_) {
      // Fall back to no route line; distance/duration simply won't show.
    }
    return null;
  }

  void _clearDestination() {
    setState(() {
      _destinationController.clear();
      _selectedDestination = null;
      _routeInfo = null;
      _suggestions = [];
    });
    _destAnnotationManager?.deleteAll();
    unawaited(_removeRouteLineLayer());
  }

  void _confirmRide() {
    final destination = _selectedDestination;
    if (destination == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Requesting a ride to ${destination.title}...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _destinationFocusNode.unfocus(),
        child: Stack(
          children: [
            MapWidget(
              key: const ValueKey('request_ride_map'),
              styleUri: isDark
                  ? MapboxStyles.DARK
                  : MapboxStyles.MAPBOX_STREETS,
              onMapCreated: _onMapCreated,
            ),

            // Back button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: _RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Search panel + suggestions
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 64, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchPanel(
                      isDark: isDark,
                      colorScheme: colorScheme,
                      destinationController: _destinationController,
                      destinationFocusNode: _destinationFocusNode,
                      isSearching: _isSearching,
                      hasDestination: _selectedDestination != null,
                      onChanged: _onDestinationChanged,
                      onClear: _clearDestination,
                    ),
                    if (_suggestions.isNotEmpty)
                      _SuggestionsList(
                        isDark: isDark,
                        colorScheme: colorScheme,
                        suggestions: _suggestions,
                        onSelect: _selectSuggestion,
                      ),
                  ],
                ),
              ),
            ),

            // Trip summary + confirm CTA
            if (_selectedDestination != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: _TripSummaryCard(
                    isDark: isDark,
                    colorScheme: colorScheme,
                    destination: _selectedDestination!,
                    routeInfo: _routeInfo,
                    isLoading: _isRoutingLoading,
                    onConfirm: _confirmRide,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Small presentational widgets
// ---------------------------------------------------------------------

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: colorScheme.onSurface, size: 20),
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.isDark,
    required this.colorScheme,
    required this.destinationController,
    required this.destinationFocusNode,
    required this.isSearching,
    required this.hasDestination,
    required this.onChanged,
    required this.onClear,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final TextEditingController destinationController;
  final FocusNode destinationFocusNode;
  final bool isSearching;
  final bool hasDestination;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup row (fixed to current location for now)
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Current location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 4.5),
                SizedBox(
                  height: 16,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1.5,
                    color: (isDark ? Colors.white24 : Colors.black12),
                  ),
                ),
              ],
            ),
          ),
          // Destination row
          Row(
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
                  controller: destinationController,
                  focusNode: destinationFocusNode,
                  autofocus: true,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Where are you going?',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isSearching)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              else if (destinationController.text.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.cancel,
                    size: 18,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.isDark,
    required this.colorScheme,
    required this.suggestions,
    required this.onSelect,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final List<Map<String, dynamic>> suggestions;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 56,
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return ListTile(
            onTap: () => onSelect(item),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({
    required this.isDark,
    required this.colorScheme,
    required this.destination,
    required this.routeInfo,
    required this.isLoading,
    required this.onConfirm,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final _RideDestination destination;
  final _RouteInfo? routeInfo;
  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DROPPING OFF AT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      destination.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              else if (routeInfo != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      routeInfo!.distanceLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      routeInfo!.durationLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirm Ride',
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------

class _RideDestination {
  const _RideDestination({
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });

  final String title;
  final String subtitle;
  final double lat;
  final double lng;
}

class _RouteInfo {
  const _RouteInfo({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<List<double>> coordinates;
  final double distanceMeters;
  final double durationSeconds;

  String get distanceLabel =>
      '${(distanceMeters / 1000).toStringAsFixed(1)} km';

  String get durationLabel {
    final minutes = (durationSeconds / 60).round();
    return '$minutes min';
  }
}
