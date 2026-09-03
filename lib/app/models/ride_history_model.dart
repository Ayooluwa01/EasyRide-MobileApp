class RideHistoryResponse {
  final bool success;
  final int statusCode;
  final RideHistoryData data;

  RideHistoryResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory RideHistoryResponse.fromJson(Map<String, dynamic> json) {
    return RideHistoryResponse(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      data: RideHistoryData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class RideHistoryData {
  final List<RideHistoryModel> rides;

  RideHistoryData({required this.rides});

  factory RideHistoryData.fromJson(Map<String, dynamic> json) {
    return RideHistoryData(
      rides: (json['rides'] as List)
          .map(
            (ride) => RideHistoryModel.fromJson(ride as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class RideHistoryModel {
  final String id;
  final String riderId;
  final String driverId;
  final String pickupAddress;
  final String dropoffAddress;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String fareEstimate;
  final String? fareFinal;
  final double? distanceKm;
  final DateTime requestedAt;
  final DateTime? matchedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final RideHistoryDriver? driver;

  RideHistoryModel({
    required this.id,
    required this.riderId,
    required this.driverId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.fareEstimate,
    this.fareFinal,
    this.distanceKm,
    required this.requestedAt,
    this.matchedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.driver,
  });

  factory RideHistoryModel.fromJson(Map<String, dynamic> json) {
    return RideHistoryModel(
      id: json['id'] as String,
      riderId: json['riderId'] as String,
      driverId: json['driverId'] as String,
      pickupAddress: json['pickupAddress'] as String,
      dropoffAddress: json['dropoffAddress'] as String,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      fareEstimate: json['fareEstimate'] as String,
      fareFinal: json['fareFinal'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      matchedAt: json['matchedAt'] != null
          ? DateTime.parse(json['matchedAt'] as String)
          : null,
      driverArrivedAt: json['driverArrivedAt'] != null
          ? DateTime.parse(json['driverArrivedAt'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancelledBy: json['cancelledBy'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      driver: json['driver'] != null
          ? RideHistoryDriver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RideHistoryDriver {
  final RideHistoryDriverUser? user;
  RideHistoryDriver({this.user});
  factory RideHistoryDriver.fromJson(Map<String, dynamic> json) {
    return RideHistoryDriver(
      user: json['user'] != null
          ? RideHistoryDriverUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RideHistoryDriverUser {
  final String fullName;
  final String phone;
  final String? profilePhotoUrl;

  RideHistoryDriverUser({
    required this.fullName,
    required this.phone,
    this.profilePhotoUrl,
  });

  factory RideHistoryDriverUser.fromJson(Map<String, dynamic> json) {
    return RideHistoryDriverUser(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}
