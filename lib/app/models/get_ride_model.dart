class GetRideByIdResponse {
  final bool success;
  final int statusCode;
  final GetRideByIdModel data;

  GetRideByIdResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory GetRideByIdResponse.fromJson(Map<String, dynamic> json) {
    return GetRideByIdResponse(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      data: GetRideByIdModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class GetRideByIdModel {
  final String id;
  final String riderId;
  final String? driverId;
  final String? pickupAddress;
  final String? dropoffAddress;
  final String
  status; // REQUESTED, DRIVER_SELECTED, MATCHED, DRIVER_ARRIVED, IN_PROGRESS, COMPLETED, CANCELLED
  final String paymentMethod;
  final String paymentStatus; // PENDING, PAID, FAILED
  final double? fareEstimate;
  final double? fareFinal;
  final double? distanceKm;
  final DateTime requestedAt;
  final DateTime? matchedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelledBy; // RIDER, DRIVER, ADMIN
  final String? cancellationReason;
  final RideRiderInfo rider;
  final RideDriverInfo? driver;
  final RideDriverLocation? driverLocation;

  GetRideByIdModel({
    required this.id,
    required this.riderId,
    this.driverId,
    this.pickupAddress,
    this.dropoffAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.fareEstimate,
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
    required this.rider,
    this.driver,
    this.driverLocation,
  });

  factory GetRideByIdModel.fromJson(Map<String, dynamic> json) {
    return GetRideByIdModel(
      id: json['id'] as String,
      riderId: json['riderId'] as String,
      driverId: json['driverId'] as String?,
      pickupAddress: json['pickupAddress'] as String?,
      dropoffAddress: json['dropoffAddress'] as String?,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      fareEstimate: json['fareEstimate'] != null
          ? double.tryParse(json['fareEstimate'].toString())
          : null,
      fareFinal: json['fareFinal'] != null
          ? double.tryParse(json['fareFinal'].toString())
          : null,
      distanceKm: json['distanceKm'] != null
          ? double.tryParse(json['distanceKm'].toString())
          : null,
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
      rider: RideRiderInfo.fromJson(json['rider'] as Map<String, dynamic>),
      driver: json['driver'] != null
          ? RideDriverInfo.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      driverLocation: json['driverLocation'] != null
          ? RideDriverLocation.fromJson(
              json['driverLocation'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class RideRiderInfo {
  final String id;
  final String userId;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String onboardingStep;
  final RideUserInfo user;

  RideRiderInfo({
    required this.id,
    required this.userId,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.onboardingStep,
    required this.user,
  });

  factory RideRiderInfo.fromJson(Map<String, dynamic> json) {
    return RideRiderInfo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      onboardingStep: json['onboardingStep'] as String,
      user: RideUserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

// Trimmed driver model — matches the tightened `driver.select` in the service
class RideDriverInfo {
  final String id;
  final String userId;
  final String? vehiclePlate;
  final String? vehicleType;
  final String? vehicleColor;
  final int? vehicleYear;
  final bool isOnline;
  final RideUserInfo user;

  RideDriverInfo({
    required this.id,
    required this.userId,
    this.vehiclePlate,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleYear,
    required this.isOnline,
    required this.user,
  });

  factory RideDriverInfo.fromJson(Map<String, dynamic> json) {
    return RideDriverInfo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      vehicleYear: json['vehicleYear'] as int?,
      isOnline: json['isOnline'] as bool,
      user: RideUserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

// name, pic, phone — shared by rider and driver
class RideUserInfo {
  final String id;
  final String fullName;
  final String? profilePhotoUrl;
  final String phone;

  RideUserInfo({
    required this.id,
    required this.fullName,
    this.profilePhotoUrl,
    required this.phone,
  });

  factory RideUserInfo.fromJson(Map<String, dynamic> json) {
    return RideUserInfo(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      phone: json['phone'] as String,
    );
  }
}

class RideDriverLocation {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final bool isOnline;
  final DateTime updatedAt;
  final bool isStale;

  RideDriverLocation({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    required this.isOnline,
    required this.updatedAt,
    required this.isStale,
  });

  factory RideDriverLocation.fromJson(Map<String, dynamic> json) {
    return RideDriverLocation(
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      heading: json['heading'] != null
          ? double.tryParse(json['heading'].toString())
          : null,
      speed: json['speed'] != null
          ? double.tryParse(json['speed'].toString())
          : null,
      accuracy: json['accuracy'] != null
          ? double.tryParse(json['accuracy'].toString())
          : null,
      isOnline: json['isOnline'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isStale: json['isStale'] as bool,
    );
  }
}
