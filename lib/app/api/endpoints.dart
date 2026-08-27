class Endpoints {
  static const String checkPhone = '/auth/check-phone';
  static const String signup = '/auth/signup/otp/request';
  static const String verifySignupOtp = '/auth/signup/otp/verify';
  static const String login = '/auth/login/otp/request';
  static const String verifyLoginOtp = '/auth/login/otp/verify';
  static const String resendOtp = '/auth/otp/resend';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String requestPhoneNumberChange = '/auth/phone/request-change';
  static const String verifyPhoneNumberChange = '/auth/phone/confirm-change';
  static const String getMe = '/user/me';
}

class AuthRoutes {
  static const Set<String> routes = {
    Endpoints.refreshToken,
    Endpoints.login,
    Endpoints.resendOtp,
    Endpoints.verifyLoginOtp,
    Endpoints.verifySignupOtp,
    Endpoints.signup,
    Endpoints.requestPhoneNumberChange,
    Endpoints.verifyPhoneNumberChange,
  };

  static bool isAuthRoute(String path) {
    return routes.any((route) => path.contains(route));
  }
}
