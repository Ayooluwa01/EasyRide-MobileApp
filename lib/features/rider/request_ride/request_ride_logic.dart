// ignore_for_file: invalid_use_of_protected_member, library_private_types_in_public_api

part of 'request_ride_screen.dart';

extension RequestRideLogic on _RequestRideScreenState {
  Future<void> _onMapCreated(MapboxMap controller) async {
    _mapboxController = controller;

    await controller.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    _pickupAnnotationManager = await controller.annotations
        .createCircleAnnotationManager();
    _destAnnotationManager = await controller.annotations
        .createCircleAnnotationManager();
    _driversAnnotationManager = await controller.annotations
        .createCircleAnnotationManager(); // new

    final pickup = _pickupLatLng;
    await _drawPickupMarker(pickup.lat, pickup.lng);

    final nearby = ref.read(nearbyDriversProvider);
    final drivers =
        (nearby is Map ? nearby['drivers'] as List<dynamic>? : null) ?? [];
    await _updateDriverMarkers(drivers);

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

  Future<void> _updateDriverMarkers(List<dynamic> drivers) async {
    final manager = _driversAnnotationManager;
    if (manager == null) return;

    final incomingIds = <String>{};
    for (int i = 0; i < drivers.length; i++) {
      final driver = drivers[i];
      final id = '${driver['driverId']}';
      final lat = (driver['latitude'] as num?)?.toDouble();
      final lng = (driver['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      incomingIds.add(id);
      final point = Point(coordinates: Position(lng, lat));
      final existing = _driverAnnotations[id];

      if (existing != null) {
        existing.geometry = point;
        await manager.update(existing);
      } else {
        final created = await manager.create(
          CircleAnnotationOptions(
            geometry: point,
            circleRadius: 7,
            circleColor: const Color.fromARGB(255, 42, 12, 12).toARGB32(),
            circleStrokeWidth: 2.5,
            circleStrokeColor: Colors.white.toARGB32(),
          ),
        );
        _driverAnnotations[id] = created;
      }
    }

    final staleIds = _driverAnnotations.keys
        .where((id) => !incomingIds.contains(id))
        .toList();

    for (int i = 0; i < staleIds.length; i++) {
      final annotation = _driverAnnotations.remove(staleIds[i]);
      if (annotation != null) await manager.delete(annotation);
    }
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
        GeoJsonSource(
          id: _RequestRideScreenState._routeSourceId,
          data: routeGeoJson,
        ),
      );

      await controller.style.addLayer(
        LineLayer(
          id: _RequestRideScreenState._routeCasingLayerId,
          sourceId: _RequestRideScreenState._routeSourceId,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,
          lineWidth: 9,
          lineColor: Colors.black.toARGB32(),
          lineOpacity: 0.25,
        ),
      );

      await controller.style.addLayer(
        LineLayer(
          id: _RequestRideScreenState._routeLineLayerId,
          sourceId: _RequestRideScreenState._routeSourceId,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,
          lineWidth: 5,
          lineColor: primaryColor.toARGB32(),
        ),
      );

      _hasRouteLayer = true;
    } else {
      await controller.style.setStyleSourceProperty(
        _RequestRideScreenState._routeSourceId,
        'data',
        routeGeoJson,
      );
    }
  }

  Future<void> _removeRouteLineLayer() async {
    final controller = _mapboxController;
    if (controller == null || !_hasRouteLayer) return;
    try {
      await controller.style.removeStyleLayer(
        _RequestRideScreenState._routeLineLayerId,
      );
      await controller.style.removeStyleLayer(
        _RequestRideScreenState._routeCasingLayerId,
      );
      await controller.style.removeStyleSource(
        _RequestRideScreenState._routeSourceId,
      );
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
    try {
      final response = await ref
          .read(suggestionsServiceProvider)
          .getLocationSuggestion(query);
      return response.data.map((data) {
        return {
          'title': data.title,
          'subtitle': data.subtitle,
          'lng': data.lng.toDouble(),
          'lat': data.lat.toDouble(),
        };
      }).toList();
    } catch (error) {
      return [];
    }
  }

  // ---------------------------------------------------------------------
  // Route (Mapbox Directions)
  // ---------------------------------------------------------------------

  Future<void> _selectSuggestion(Map<String, dynamic> place) async {
    final colorScheme = Theme.of(context).colorScheme;
    _destinationFocusNode.unfocus();
    _debounceTimer?.cancel();

    final destination = RideDestination(
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

  Future<RouteInfo?> _fetchDrivingRoute({
    required ({double lat, double lng}) pickup,
    required RideDestination destination,
  }) async {
    final request = GetRouteRequest(
      originLng: pickup.lng,
      originLat: pickup.lat,
      destLng: destination.lng,
      destLat: destination.lat,
    );

    try {
      final response = await ref.read(routeServiceProvider).getRoute(request);
      final route = response.data;
      return RouteInfo(
        coordinates: route.coordinates
            .map<List<double>>(
              (c) => [(c[0] as num).toDouble(), (c[1] as num).toDouble()],
            )
            .toList(),
        distanceMeters: route.distanceMeters.toDouble(),
        durationSeconds: route.durationSeconds.toDouble(),
        baseFare: route.baseFare,
      );
    } catch (_) {
      return null;
    }
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

  Future<void> _confirmRide(num offeredFare) async {
    final destination = _selectedDestination;
    final paymentMethod = _selectedPaymentMethod;

    if (destination == null || _isConfirmingRide) return;

    final pickup = _pickupLatLng;

    final request = RequestRideModel(
      pickupLat: pickup.lat,
      pickupLng: pickup.lng,
      dropoffLat: destination.lat,
      dropoffLng: destination.lng,
      pickupAddress: 'Current location',
      dropoffAddress: destination.title,
      paymentMethod: paymentMethod?.name,
      fare: offeredFare,
    );

    setState(() {
      _isConfirmingRide = true;
    });

    try {
      final response = await ref.read(requestRideProvider).requestRide(request);

      if (!mounted) return;
      final rideId = response.data.rideId;

      ref.read(driverOfferProvider.notifier).setRide(rideId);
      // ref.read(driverOfferProvider);
      setState(() {
        _isConfirmingRide = false;
        _searchNearbyDrivers = true;
        _rideId = response.data.rideId;
        _nearbyDriversCount = response.data.nearbyDrivers;
      });
    } catch (error, stackTrace) {
      developer.log(
        'REQUEST RIDE FAILED',
        name: 'RequestRideScreen',
        error: error,
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        _isConfirmingRide = false;
      });
    }
  }

  Widget paymentCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final selected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.1),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
