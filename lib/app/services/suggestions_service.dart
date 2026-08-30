import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuggestionsService {
  final Ref ref;

  SuggestionsService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<LocationSuggestionResponse> getLocationSuggestion(
    String location,
  ) async {
    final encodedLocation = Uri.encodeComponent(location);

    final response = await _apiClient.get('/mapbox/locations/$encodedLocation');

    return LocationSuggestionResponse.fromJson(response.data);
  }
}

final suggestionsServiceProvider = Provider<SuggestionsService>((ref) {
  return SuggestionsService(ref);
});
