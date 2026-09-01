class RequestRideModel {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String? paymentMethod;
  final String? pickupAddress;
  final String? dropoffAddress;
  final num fare;
  const RequestRideModel({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.fare,
    this.paymentMethod,
    this.pickupAddress,
    this.dropoffAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'paymentMethod': paymentMethod,
      'fare': fare,
    };
  }
}

class RequestRideResponseModel {
  final bool success;
  final RequestRideResponseData data;

  const RequestRideResponseModel({required this.success, required this.data});

  factory RequestRideResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestRideResponseModel(
      success: json['success'] as bool,
      data: RequestRideResponseData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class RequestRideResponseData {
  final String rideId;
  final String status;
  final int nearbyDrivers;

  const RequestRideResponseData({
    required this.rideId,
    required this.status,
    required this.nearbyDrivers,
  });

  factory RequestRideResponseData.fromJson(Map<String, dynamic> json) {
    return RequestRideResponseData(
      rideId: json['rideId'] as String,
      status: json['status'] as String,
      nearbyDrivers: (json['nearbyDrivers'] as num).toInt(),
    );
  }
}
