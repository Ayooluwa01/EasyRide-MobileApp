class User {
  final String? id;
  final String? phone;
  final String? role;
  final String? fullName;
  final String? email;
  final String? profilePhotoUrl;
  final bool isPhoneVerified;
  final String? onboardingStatus;
  final int tokenVersion;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  // Driver side
  final DriverProfile? driverProfile;

  User({
    this.id,
    this.phone,
    this.role,
    this.fullName,
    this.email,
    this.profilePhotoUrl,
    this.isPhoneVerified = false,
    this.onboardingStatus,
    this.tokenVersion = 0,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.driverProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final driverProfileJson = json['driverProfile'];

    return User(
      id: json['id'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      onboardingStatus: json['onboardingStatus'] as String?,
      tokenVersion: json['tokenVersion'] as int? ?? 0,
      deletedAt: json['deletedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,

      driverProfile: driverProfileJson is Map<String, dynamic>
          ? DriverProfile.fromJson(driverProfileJson)
          : null,
    );
  }
}

class DriverProfile {
  final String? id;
  final String? userId;
  final String? dateOfBirth;
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
  bool isOnline;

  final String? createdAt;
  final String? updatedAt;

  DriverProfile({
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
    this.isOnline = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      vehicleYear: json['vehicleYear'] as int?,

      licenseFrontUrl: json['licenseFrontUrl'] as String?,
      licenseBackUrl: json['licenseBackUrl'] as String?,
      vehicleRegistrationUrl: json['vehicleRegistrationUrl'] as String?,
      insuranceUrl: json['insuranceUrl'] as String?,
      driverPhotoUrl: json['driverPhotoUrl'] as String?,

      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankAccountName: json['bankAccountName'] as String?,

      onboardingStep: json['onboardingStep'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,

      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
