class User {
  final String id;
  final String phone;
  final String role;
  final String fullName;
  final String email;
  final String? profilePhotoUrl;
  final bool isPhoneVerified;
  final String onboardingStatus;
  final int tokenVersion;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.phone,
    required this.role,
    required this.fullName,
    required this.email,
    this.profilePhotoUrl,
    required this.isPhoneVerified,
    required this.onboardingStatus,
    required this.tokenVersion,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      onboardingStatus: json['onboardingStatus'] as String,
      tokenVersion: json['tokenVersion'] as int? ?? 0,
      deletedAt: json['deletedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
