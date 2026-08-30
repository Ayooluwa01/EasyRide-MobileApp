import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteService {
  final Ref ref;

  RouteService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<GetRouteResponse> getRoute(GetRouteRequest request) async {
    final response = await _apiClient.get(
      Endpoints.getRoute,
      queryParameters: request.toQueryParameters(),
    );
    return GetRouteResponse.fromJson(response.data);
  }
}

final routeServiceProvider = Provider<RouteService>((ref) {
  return RouteService(ref);
});
