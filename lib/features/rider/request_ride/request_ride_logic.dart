// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member, library_private_types_in_public_api

part of 'request_ride_screen.dart';

extension RequestRideLogic on _RequestRideScreenState {
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    final pickup = _pickupLatLng;
    _drawPickupMarker(pickup.lat, pickup.lng);

    final nearby = ref.read(nearbyDriversProvider);
    final drivers =
        (nearby is Map ? nearby['drivers'] as List<dynamic>? : null) ?? [];
    await _updateDriverMarkers(drivers);

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(pickup.lat, pickup.lng), zoom: 15.5),
      ),
    );
  }

  void _drawPickupMarker(double lat, double lng) {
    setState(() {
      _pickupMarkers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            anchor: const Offset(0.5, 0.5),
            zIndex: 2,
          ),
        );
    });
  }

  Future<void> _updateDriverMarkers(List<dynamic> drivers) async {
    final incomingIds = <String>{};
    final updatedMarkers = <String, Marker>{};

    for (int i = 0; i < drivers.length; i++) {
      final driver = drivers[i];
      final id = '${driver['driverId']}';
      final lat = (driver['latitude'] as num?)?.toDouble();
      final lng = (driver['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      incomingIds.add(id);
      updatedMarkers[id] = Marker(
        markerId: MarkerId('driver_$id'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        anchor: const Offset(0.5, 0.5),
        zIndex: 1,
      );
    }

    if (!mounted) return;
    setState(() {
      _driverAnnotations
        ..clear()
        ..addAll(updatedMarkers);
      _driverMarkers
        ..clear()
        ..addAll(updatedMarkers.values);
    });
  }

  void _drawDestinationMarker(double lat, double lng, Color primary) {
    setState(() {
      _destMarkers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            anchor: const Offset(0.5, 0.5),
            zIndex: 2,
          ),
        );
    });
  }

  Future<void> _drawRoute(
    List<List<double>> coordinates,
    Color primaryColor,
  ) async {
    if (coordinates.isEmpty) return;

    final points = coordinates
        .map((c) => LatLng(c[1], c[0]))
        .toList(growable: false);

    setState(() {
      _routePolylines = {
        Polyline(
          polylineId: const PolylineId('route-casing'),
          points: points,
          color: Colors.black.withValues(alpha: 0.25),
          width: 9,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 0,
        ),
        Polyline(
          polylineId: const PolylineId('route-line'),
          points: points,
          color: primaryColor,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 1,
        ),
      };
      _hasRouteLayer = true;
    });
  }

  Future<void> _removeRoute() async {
    if (!_hasRouteLayer) return;
    setState(() {
      _routePolylines = {};
      _hasRouteLayer = false;
    });
  }

  Future<void> _fitCameraToRoute({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
    required double distanceKm,
  }) async {
    final controller = _mapController;
    if (controller == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(pickupLat, destLat),
        math.min(pickupLng, destLng),
      ),
      northeast: LatLng(
        math.max(pickupLat, destLat),
        math.max(pickupLng, destLng),
      ),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  // ---------------------------------------------------------------------
  // Search — Places Autocomplete, suggestions carry placeId (no coords yet)
  // ---------------------------------------------------------------------

  void _onDestinationChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    final requestId = ++_searchRequestId;

    if (_selectedDestination != null) {
      setState(() {
        _selectedDestination = null;
        _routeInfo = null;
        _destMarkers.clear();
      });
      unawaited(_removeRoute());
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
      final results = await _fetchSuggestions(trimmed);
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchSuggestions(String query) async {
    final pickup = _pickupLatLng;
    try {
      final response = await ref
          .read(suggestionsServiceProvider)
          .getLocationSuggestion(
            query,
            _sessionToken,
            pickup.lat.toString(),
            pickup.lng.toString(),
          );
      return response.data.map((s) {
        return {'title': s.title, 'subtitle': s.subtitle, 'placeId': s.placeId};
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------
  // Selection —
  // ---------------------------------------------------------------------

  Future<void> _selectSuggestion(Map<String, dynamic> place) async {
    final colorScheme = Theme.of(context).colorScheme;
    _destinationFocusNode.unfocus();
    _debounceTimer?.cancel();

    final placeId = place['placeId'] as String;
    final title = place['title'] as String;

    setState(() {
      _suggestions = [];
      _isRoutingLoading = true;
      _routeInfo = null;
      _selectedDestination = null;
    });
    _destinationController.text = title;

    PlaceDetails details;
    try {
      final response = await ref
          .read(suggestionsServiceProvider)
          .getPlaceDetails(placeId);
      details = response.data;
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRoutingLoading = false);
      return;
    }

    final destination = RideDestination(
      title: title,
      subtitle: details.address,
      lat: details.latitude,
      lng: details.longitude,
    );

    if (!mounted) return;
    setState(() => _selectedDestination = destination);

    _drawDestinationMarker(
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
      await _drawRoute(route.coordinates, colorScheme.primary);
    }

    _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();
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

      final decoded = PolylinePoints.decodePolyline(route.polyline);
      final coordinates = decoded
          .map((point) => [point.longitude, point.latitude])
          .toList();

      return RouteInfo(
        coordinates: coordinates,
        distanceMeters: route.distanceMeters,
        durationSeconds: route.durationSeconds,
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
      _destMarkers.clear();
    });
    unawaited(_removeRoute());
    _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> _confirmRide(num offeredFare) async {
    final destination = _selectedDestination;
    final paymentMethod = _selectedPaymentMethod;

    if (destination == null || _isConfirmingRide) return;

    final pickup = _pickupLatLng;

    setState(() {
      _isConfirmingRide = true;
    });

    // Resolve pickup address only now, once, using the freshest coordinates
    String pickupAddress = '';
    try {
      final response = await ref
          .read(suggestionsServiceProvider)
          .reverseGeocode(pickup.lat, pickup.lng);
      print('response ${response.data.address}');
      pickupAddress = response.data.address;
    } catch (_) {
      // fall back to placeholder if reverse geocoding fails — don't block the ride
    }

    final request = RequestRideModel(
      pickupLat: pickup.lat,
      pickupLng: pickup.lng,
      dropoffLat: destination.lat,
      dropoffLng: destination.lng,
      pickupAddress: pickupAddress,
      dropoffAddress: destination.title,
      paymentMethod: paymentMethod.name,
      fare: offeredFare,
    );

    try {
      final response = await ref.read(requestRideProvider).requestRide(request);

      if (!mounted) return;
      final rideId = response.data.rideId;

      ref.read(driverOfferProvider.notifier).setRide(rideId);
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
