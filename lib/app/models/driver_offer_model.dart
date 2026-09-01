class AcceptDriverOfferModel {
  final bool success;
  final int? statusCode;
  final String? rideId;
  final String? status;
  final String? paymentMethod;
  final double? fare;
  final String? pickupAddress;
  final String? dropoffAddress;
  final String? driverId;

  AcceptDriverOfferModel({
    required this.success,
    this.statusCode,
    this.rideId,
    this.status,
    this.paymentMethod,
    this.fare,
    this.pickupAddress,
    this.dropoffAddress,
    this.driverId,
  });

  factory AcceptDriverOfferModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return AcceptDriverOfferModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int?,
      rideId: data['rideId'] as String?,
      status: data['status'] as String?,
      paymentMethod: data['PaymentMethod'] as String?,
      fare: double.tryParse('${data['fare']}'),
      pickupAddress: data['pickupAddress'] as String?,
      dropoffAddress: data['dropoffAddress'] as String?,
      driverId: data['driverId'] as String?,
    );
  }
}
