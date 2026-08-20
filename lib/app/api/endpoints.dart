class Endpoints {
  static const refreshToken = 'auth/refreshToken';
  static const login = '/auth/login/otp/request';
  static const verifyLoginOtp = '/auth/login/verify';
}

class AuthRoutes {
  static const Set<String> routes = {
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
  };

  static bool isAuthRoute(String path) {
    return routes.any((route) => path.contains(route));
  }
}
