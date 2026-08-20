class Endpoints {
  static const refreshToken = 'auth/refreshToken';
  static const login = '/auth/login/otp/request';
  static const verifyLoginOtp = '/auth/login/verify';
  static const signup = '/auth/signup/otp/request';
  static const verifySignupOtp = '/auth/signup/otp/verify';
  static const resendOtp = '/auth/otp/resend';
  static const requestPhoneNumberChange = '/auth/phone/request-change';
  static const verifyPhoneNumberChange = '/auth/phone/confirm-change';
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
