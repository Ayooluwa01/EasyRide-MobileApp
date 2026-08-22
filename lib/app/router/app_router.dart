import 'package:easy_ride/features/auth/screens/get_started.dart';
import 'package:easy_ride/features/auth/screens/otp_screen.dart';
import 'package:easy_ride/features/auth/screens/signup_screen.dart';
import 'package:easy_ride/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,

  routes: [
    GoRoute(
      path: RouteNames.splash,
      name: "Splash",
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: RouteNames.getstarted,
      name: "getStarted",
      builder: (context, state) {
        return const GetStarted();
      },
    ),
    GoRoute(
      path: RouteNames.signup,
      name: "signup",
      builder: (context, state) {
        return const SignupScreen();
      },
    ),
    GoRoute(
      path: RouteNames.otp,
      name: "otp",
      builder: (context, state) {
        return const OtpScreen();
      },
    ),
    // GoRoute(
    //   path: RouteNames.register,
    //   name: 'register',
    //   builder: (context, state) {
    //     return const RegisterScreen();
    //   },
    // ),

    // GoRoute(
    //   path: RouteNames.home,
    //   name: 'home',
    //   builder: (context, state) {
    //     return const HomeScreen();
    //   },
    // ),
  ],
);
