class RiderActiveRideModel {
  final String? id;
  final String? riderId;
  final String? driverId;

  final String? pickupAddress;
  final String? dropoffAddress;

  final String? status;
  final String? paymentMethod;
  final String? paymentStatus;

  final double? fareEstimate;
  final double? fareFinal;
  final double? distanceKm;

  final DateTime? requestedAt;
  final DateTime? matchedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final String? cancelledBy;
  final String? cancellationReason;

  final DriverActiveRideInfo? driver;
  final LocationPoint? pickupLocation;
  final LocationPoint? dropoffLocation;
  final DriverLocationModel? driverLocation;

  RiderActiveRideModel({
    this.id,
    this.riderId,
    this.driverId,
    this.pickupAddress,
    this.dropoffAddress,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.fareEstimate,
    this.fareFinal,
    this.distanceKm,
    this.requestedAt,
    this.matchedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.driver,
    this.pickupLocation,
    this.dropoffLocation,
    this.driverLocation,
  });

  factory RiderActiveRideModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return RiderActiveRideModel(
      id: data['id']?.toString(),
      riderId: data['riderId']?.toString(),
      driverId: data['driverId']?.toString(),

      pickupAddress: data['pickupAddress']?.toString(),
      dropoffAddress: data['dropoffAddress']?.toString(),

      status: data['status']?.toString(),
      paymentMethod: data['paymentMethod']?.toString(),
      paymentStatus: data['paymentStatus']?.toString(),

      fareEstimate: _double(data['fareEstimate']),
      fareFinal: _double(data['fareFinal']),
      distanceKm: _double(data['distanceKm']),

      requestedAt: _date(data['requestedAt']),
      matchedAt: _date(data['matchedAt']),
      driverArrivedAt: _date(data['driverArrivedAt']),
      startedAt: _date(data['startedAt']),
      completedAt: _date(data['completedAt']),
      cancelledAt: _date(data['cancelledAt']),

      cancelledBy: data['cancelledBy']?.toString(),
      cancellationReason: data['cancellationReason']?.toString(),

      driver: data['driver'] is Map<String, dynamic>
          ? DriverActiveRideInfo.fromJson(
              data['driver'] as Map<String, dynamic>,
            )
          : null,

      pickupLocation: data['pickupLocation'] is Map<String, dynamic>
          ? LocationPoint.fromJson(
              data['pickupLocation'] as Map<String, dynamic>,
            )
          : null,

      dropoffLocation: data['dropoffLocation'] is Map<String, dynamic>
          ? LocationPoint.fromJson(
              data['dropoffLocation'] as Map<String, dynamic>,
            )
          : null,

      driverLocation: data['driverLocation'] is Map<String, dynamic>
          ? DriverLocationModel.fromJson(
              data['driverLocation'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

// ============================================================
// DRIVER ACTIVE RIDE
// ============================================================

class DriverActiveRideModel {
  final String? id;
  final String? riderId;
  final String? driverId;

  final String? pickupAddress;
  final String? dropoffAddress;

  final String? status;
  final String? paymentMethod;
  final String? paymentStatus;

  final double? fareEstimate;
  final double? fareFinal;
  final double? distanceKm;

  final DateTime? requestedAt;
  final DateTime? matchedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final String? cancelledBy;
  final String? cancellationReason;

  final RiderActiveRideInfo? rider;
  final LocationPoint? pickupLocation;
  final LocationPoint? dropoffLocation;
  final DriverLocationModel? driverLocation;

  DriverActiveRideModel({
    this.id,
    this.riderId,
    this.driverId,
    this.pickupAddress,
    this.dropoffAddress,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.fareEstimate,
    this.fareFinal,
    this.distanceKm,
    this.requestedAt,
    this.matchedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.rider,
    this.pickupLocation,
    this.dropoffLocation,
    this.driverLocation,
  });

  factory DriverActiveRideModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return DriverActiveRideModel(
      id: data['id']?.toString(),
      riderId: data['riderId']?.toString(),
      driverId: data['driverId']?.toString(),

      pickupAddress: data['pickupAddress']?.toString(),
      dropoffAddress: data['dropoffAddress']?.toString(),

      status: data['status']?.toString(),
      paymentMethod: data['paymentMethod']?.toString(),
      paymentStatus: data['paymentStatus']?.toString(),

      fareEstimate: _double(data['fareEstimate']),
      fareFinal: _double(data['fareFinal']),
      distanceKm: _double(data['distanceKm']),

      requestedAt: _date(data['requestedAt']),
      matchedAt: _date(data['matchedAt']),
      driverArrivedAt: _date(data['driverArrivedAt']),
      startedAt: _date(data['startedAt']),
      completedAt: _date(data['completedAt']),
      cancelledAt: _date(data['cancelledAt']),

      cancelledBy: data['cancelledBy']?.toString(),
      cancellationReason: data['cancellationReason']?.toString(),

      rider: data['rider'] is Map<String, dynamic>
          ? RiderActiveRideInfo.fromJson(data['rider'] as Map<String, dynamic>)
          : null,

      pickupLocation: data['pickupLocation'] is Map<String, dynamic>
          ? LocationPoint.fromJson(
              data['pickupLocation'] as Map<String, dynamic>,
            )
          : null,

      dropoffLocation: data['dropoffLocation'] is Map<String, dynamic>
          ? LocationPoint.fromJson(
              data['dropoffLocation'] as Map<String, dynamic>,
            )
          : null,

      driverLocation: data['driverLocation'] is Map<String, dynamic>
          ? DriverLocationModel.fromJson(
              data['driverLocation'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

// ============================================================
// DRIVER INFO
// ============================================================

class DriverActiveRideInfo {
  final String? id;
  final String? userId;

  final DateTime? dateOfBirth;

  final String? licenseNumber;
  final String? vehiclePlate;
  final String? vehicleType;
  final String? vehicleColor;

  final int? vehicleYear;

  final String? licenseFrontUrl;
  final String? licenseBackUrl;
  final String? vehicleRegistrationUrl;
  final String? insuranceUrl;
  final String? driverPhotoUrl;

  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;

  final String? onboardingStep;
  final String? verificationStatus;

  final bool? isOnline;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final DriverUserInfo? user;

  DriverActiveRideInfo({
    this.id,
    this.userId,
    this.dateOfBirth,
    this.licenseNumber,
    this.vehiclePlate,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleYear,
    this.licenseFrontUrl,
    this.licenseBackUrl,
    this.vehicleRegistrationUrl,
    this.insuranceUrl,
    this.driverPhotoUrl,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.onboardingStep,
    this.verificationStatus,
    this.isOnline,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory DriverActiveRideInfo.fromJson(Map<String, dynamic> json) {
    return DriverActiveRideInfo(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),

      dateOfBirth: _date(json['dateOfBirth']),

      licenseNumber: json['licenseNumber']?.toString(),
      vehiclePlate: json['vehiclePlate']?.toString(),
      vehicleType: json['vehicleType']?.toString(),
      vehicleColor: json['vehicleColor']?.toString(),

      vehicleYear: _int(json['vehicleYear']),

      licenseFrontUrl: json['licenseFrontUrl']?.toString(),
      licenseBackUrl: json['licenseBackUrl']?.toString(),
      vehicleRegistrationUrl: json['vehicleRegistrationUrl']?.toString(),
      insuranceUrl: json['insuranceUrl']?.toString(),
      driverPhotoUrl: json['driverPhotoUrl']?.toString(),

      bankName: json['bankName']?.toString(),
      bankAccountNumber: json['bankAccountNumber']?.toString(),
      bankAccountName: json['bankAccountName']?.toString(),

      onboardingStep: json['onboardingStep']?.toString(),
      verificationStatus: json['verificationStatus']?.toString(),

      isOnline: json['isOnline'] as bool?,

      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),

      user: json['user'] is Map<String, dynamic>
          ? DriverUserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ============================================================
// DRIVER USER
// ============================================================

class DriverUserInfo {
  final String? id;
  final String? fullName;
  final String? profilePhotoUrl;
  final String? phone;

  DriverUserInfo({this.id, this.fullName, this.profilePhotoUrl, this.phone});

  factory DriverUserInfo.fromJson(Map<String, dynamic> json) {
    return DriverUserInfo(
      id: json['id']?.toString(),
      fullName: json['fullName']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

// ============================================================
// RIDER INFO
// ============================================================

class RiderActiveRideInfo {
  final String? id;
  final String? userId;
  final String? fullName;
  final String? profilePhotoUrl;
  final String? phone;

  final double? rating;

  RiderActiveRideInfo({
    this.id,
    this.userId,
    this.fullName,
    this.profilePhotoUrl,
    this.phone,
    this.rating,
  });

  factory RiderActiveRideInfo.fromJson(Map<String, dynamic> json) {
    return RiderActiveRideInfo(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      fullName: json['fullName']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      phone: json['phone']?.toString(),
      rating: _double(json['rating']),
    );
  }
}

// ============================================================
// LOCATION POINT
// ============================================================

class LocationPoint {
  final double? latitude;
  final double? longitude;

  LocationPoint({this.latitude, this.longitude});

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
    );
  }
}

// ============================================================
// DRIVER LOCATION
// ============================================================

class DriverLocationModel {
  final String? driverId;

  final double? latitude;
  final double? longitude;

  final double? heading;
  final double? speed;
  final double? accuracy;

  final bool? isOnline;
  final DateTime? updatedAt;

  DriverLocationModel({
    this.driverId,
    this.latitude,
    this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    this.isOnline,
    this.updatedAt,
  });

  factory DriverLocationModel.fromJson(Map<String, dynamic> json) {
    return DriverLocationModel(
      driverId: json['driverId']?.toString(),

      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),

      heading: _double(json['heading']),
      speed: _double(json['speed']),
      accuracy: _double(json['accuracy']),

      isOnline: json['isOnline'] as bool?,
      updatedAt: _date(json['updatedAt']),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

double? _double(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

int? _int(dynamic value) {
  if (value == null) return null;

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}

DateTime? _date(dynamic value) {
  if (value == null) return null;

  return DateTime.tryParse(value.toString());
}
