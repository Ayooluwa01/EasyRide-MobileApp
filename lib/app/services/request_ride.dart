import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/request_ride_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestRideService {
  final Ref ref;

  RequestRideService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  // Request a ride
  Future<RequestRideResponseModel> requestRide(RequestRideModel request) async {
    final response = await _apiClient.post(
      Endpoints.rides,
      data: request.toJson(),
    );

    debugPrint('========== REQUEST RIDE RESPONSE ==========');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('DATA: ${response.data}');
    debugPrint('DATA TYPE: ${response.data.runtimeType}');
    debugPrint('============================================');

    try {
      return RequestRideResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error, stackTrace) {
      debugPrint('========== REQUEST RIDE PARSE ERROR ==========');
      debugPrint('ERROR: $error');
      debugPrint('STACK: $stackTrace');
      debugPrint('==============================================');

      rethrow;
    }
  }
}

final requestRideProvider = Provider<RequestRideService>(
  (ref) => RequestRideService(ref),
);
