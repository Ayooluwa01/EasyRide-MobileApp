class OtpRequestModel {
  final String phone;

  OtpRequestModel({required this.phone});
  Map<String, dynamic> toJson() {
    return {'phone': phone};
  }
}

class OtpResponseModel {
  final bool success;
  final String message;

  OtpResponseModel({required this.success, required this.message});
  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? "",
    );
  }
}
