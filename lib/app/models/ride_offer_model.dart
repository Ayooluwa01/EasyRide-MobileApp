class RideOfferModel {
  final String rideId;
  final RideOfferLocation pickup;
  final RideOfferLocation dropoff;
  final num? fare;
  final double distanceFromDriverMeters;
  final String paymentMethod;

  RideOfferModel({
    required this.rideId,
    required this.pickup,
    required this.dropoff,
    this.fare,
    required this.distanceFromDriverMeters,
    required this.paymentMethod,
  });

  factory RideOfferModel.fromJson(Map<String, dynamic> json) {
    return RideOfferModel(
      rideId: json['rideId'] as String,
      pickup: RideOfferLocation.fromJson(
        json['pickup'] as Map<String, dynamic>,
      ),
      dropoff: RideOfferLocation.fromJson(
        json['dropoff'] as Map<String, dynamic>,
      ),
      fare: json['fare'] != null ? num.tryParse(json['fare'].toString()) : null,
      distanceFromDriverMeters:
          double.tryParse(json['distanceFromDriverMeters'].toString()) ?? 0,

      paymentMethod:
          (json['paymentMethod'] ?? json['PaymentMethod']) as String? ??
          'UNKNOWN',
    );
  }
}

class RideOfferLocation {
  final double lat;
  final double lng;
  final String? address;

  RideOfferLocation({required this.lat, required this.lng, this.address});

  factory RideOfferLocation.fromJson(Map<String, dynamic> json) {
    return RideOfferLocation(
      lat: double.tryParse(json['lat'].toString()) ?? 0,
      lng: double.tryParse(json['lng'].toString()) ?? 0,
      address: json['address'] as String?,
    );
  }
}
