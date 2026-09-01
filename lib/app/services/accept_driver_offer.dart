// accept_driver_offer service (formerly _Acceptoffer)
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/models/driver_offer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _AcceptOffer {
  _AcceptOffer(this.ref);
  final Ref ref;

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<AcceptDriverOfferModel> acceptOffer(
    String rideId,
    String driverId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/rides/$rideId/accept-driver',
        data: {'driverId': driverId},
      );
      developer.log('Accept driver offer response: ${response.data}');
      return AcceptDriverOfferModel.fromJson(response.data);
    } on DioException catch (e) {
      // final serverMessage = e.response?.data is Map
      //     ? (e.response!.data as Map)['message']
      //     : e.response?.data;
      developer.log(
        'Error accepting driver offer '
        '[${e.response?.statusCode}]',
      );
      rethrow;
    } catch (e) {
      developer.log('Error accepting driver offer: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectOffer(
    String rideId,
    String driverId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/rides/$rideId/reject-driver',
        data: {'driverId': driverId},
      );
      developer.log('Reject driver offer response: ${response.data}');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map
          ? (e.response!.data as Map)['message']
          : e.response?.data;
      developer.log(
        'Error rejecting driver offer '
        '[${e.response?.statusCode}]: $serverMessage',
      );
      rethrow;
    } catch (e) {
      developer.log('Error rejecting driver offer: $e');
      rethrow;
    }
  }
}

final acceptOfferProvider = Provider<_AcceptOffer>((ref) {
  return _AcceptOffer(ref);
});
