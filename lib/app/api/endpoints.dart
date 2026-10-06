class Endpoints {
  static const String checkPhone = '/auth/check-phone';
  static const String signup = '/auth/signup/otp/request';
  static const String verifySignupOtp = '/auth/signup/otp/verify';
  static const String login = '/auth/login';
  static const String verifyLoginOtp = '/auth/login/otp/verify';
  static const String resendOtp = '/auth/otp/resend';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String requestPhoneNumberChange = '/auth/phone/request-change';
  static const String verifyPhoneNumberChange = '/auth/phone/confirm-change';
  static const String getMe = '/user/me';
  static const String getLocations = '/google-map/suggestions';
  static const String getPlaceDetails = '/google-map/place-details';
  static const String getRoute = '/google-map/route';
  static const String rides = '/rides';
  static const String activeRide = '/rides/active';
  static const String rideRequets = '/rides/requests';
  static const String onlineStatus = '/user/me/online-status';
  static const String reverseGeocode = '/google-map/reverse-geocode';
  static const String createPassword = '/auth/create-password';
  static const String requestResetPassword = '/auth/password-reset/request';
  static const String verifyPasswordResetOtp =
      '/auth/password-reset/verify-otp';
  static const String resetPassword = '/auth/password-reset/reset';
  static const String sosAlert = '/safety/sos/alert';
  static const String resolveSosAlert = '/safety/sos/resolve';
  static const String driverProfileStatus = '/user/me/driver-profile';
  static const driverPersonalInfo = '/user/me/driver-profile/personal-info';
  static const driverVehicleInfo = '/user/me/driver-profile/vehicle-info';
  static const driverDocuments = '/user/me/driver-profile/documents';
  static const driverBankDetails = '/user/me/driver-profile/bank-details';
  static const driverSubmit = '/user/me/driver-profile/submit';
  static const upload = '/upload/presign'; // see the upload note below
}

class AuthRoutes {
  static const Set<String> routes = {
    Endpoints.refreshToken,
    Endpoints.login,
    Endpoints.resendOtp,
    Endpoints.verifyLoginOtp,
    Endpoints.verifySignupOtp,
    Endpoints.verifyPasswordResetOtp,
    Endpoints.signup,
    Endpoints.requestPhoneNumberChange,
    Endpoints.verifyPhoneNumberChange,
    Endpoints.requestResetPassword,
  };

  static bool isAuthRoute(String path) {
    return routes.any((route) => path.contains(route));
  }
}
