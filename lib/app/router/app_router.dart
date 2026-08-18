import 'package:easy_ride/features/auth/get_started.dart';
import 'package:easy_ride/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
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
