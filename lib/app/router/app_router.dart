import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/app/shared/bottom_nav.dart';
import 'package:easy_ride/app/shared/driver_bottom_nav.dart';
import 'package:easy_ride/app/shared/storage_keys.dart';
import 'package:easy_ride/features/auth/screens/get_started.dart';
import 'package:easy_ride/features/auth/screens/login_screen.dart';
import 'package:easy_ride/features/auth/screens/otp_screen.dart';
import 'package:easy_ride/features/auth/screens/signup_screen.dart';
import 'package:easy_ride/features/driver/driver_home_screen.dart';
import 'package:easy_ride/features/driver/driver_profile_screen.dart';
import 'package:easy_ride/features/driver/driver_ride_history_screen.dart';
import 'package:easy_ride/features/rider/active_ride/active_ride_screen.dart';
import 'package:easy_ride/features/rider/screens/chat_screen.dart';
import 'package:easy_ride/features/rider/screens/payment_method.dart';
import 'package:easy_ride/features/rider/screens/personal_information_screen.dart';
import 'package:easy_ride/features/rider/request_ride/request_ride_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_home_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_notification_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_security_screen.dart';
import 'package:easy_ride/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

const secureStorage = FlutterSecureStorage();

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  redirect: (context, state) async {
    final accessToken = await secureStorage.read(key: 'access-token');
    final role = await secureStorage.read(key: StorageKeys.userRole);
    final isAuthenticated = accessToken != null && accessToken.isNotEmpty;
    final isRider = role == 'RIDER';
    final isDriver = role == 'DRIVER';
    final location = state.matchedLocation;

    // =========================================================
    // AUTHENTICATED USER
    // =========================================================

    if (isAuthenticated) {
      // Initialize websocket once the user is authenticated.
      Websocket().initialize(accessToken);

      // -------------------------------------------------------
      // RIDER
      // -------------------------------------------------------

      if (isRider) {
        // Rider should never access driver routes.
        if (location == RouteNames.driverhomescreen) {
          return RouteNames.rider;
        }

        // Auth screens should not be accessible after login.
        if (location == RouteNames.splash ||
            location == RouteNames.login ||
            location == RouteNames.signup ||
            location == RouteNames.otp ||
            location == RouteNames.getstarted) {
          return RouteNames.rider;
        }

        return null;
      }

      // -------------------------------------------------------
      // DRIVER
      // -------------------------------------------------------

      if (isDriver) {
        // Driver should never access rider routes.
        if (location == RouteNames.rider ||
            location == RouteNames.riderhomescreen ||
            location == RouteNames.riderpaymentinformation ||
            location == RouteNames.ridersecurity ||
            location == '/requestride' ||
            location == '/activeride' ||
            location == RouteNames.chatscreen) {
          return RouteNames.driverhomescreen;
        }

        // Auth screens should not be accessible after login.
        if (location == RouteNames.splash ||
            location == RouteNames.login ||
            location == RouteNames.signup ||
            location == RouteNames.otp ||
            location == RouteNames.getstarted) {
          return RouteNames.driverhomescreen;
        }

        return null;
      }

      // -------------------------------------------------------
      // AUTHENTICATED BUT ROLE IS UNKNOWN
      // -------------------------------------------------------

      // Don't allow a user with an invalid/missing role
      // into protected application screens.
      return RouteNames.getstarted;
    }

    // =========================================================
    // NOT AUTHENTICATED
    // =========================================================

    // Make sure the socket is disconnected.
    Websocket().dispose();

    // User is not authenticated and is trying to access
    // any protected application route.
    if (location == RouteNames.rider ||
        location == RouteNames.riderhomescreen ||
        location == RouteNames.riderpaymentinformation ||
        location == RouteNames.ridersecurity ||
        location == RouteNames.chatscreen ||
        location == '/requestride' ||
        location == '/activeride' ||
        location == RouteNames.driverhomescreen) {
      return RouteNames.getstarted;
    }

    return null;
  },

  routes: [
    // =========================================================
    // AUTH
    // =========================================================
    GoRoute(
      path: RouteNames.splash,
      name: 'Splash',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),

    GoRoute(
      path: RouteNames.getstarted,
      name: 'getStarted',
      builder: (context, state) {
        return const GetStarted();
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
      path: RouteNames.signup,
      name: 'signup',
      builder: (context, state) {
        return const SignupScreen();
      },
    ),

    GoRoute(
      path: RouteNames.otp,
      name: 'otp',
      builder: (context, state) {
        return const OtpScreen();
      },
    ),

    // =========================================================
    // RIDER
    // =========================================================
    GoRoute(
      path: RouteNames.rider,
      name: 'rider',
      builder: (context, state) {
        return const BottomNav();
      },
    ),

    GoRoute(
      path: RouteNames.riderhomescreen,
      name: 'riderhomescreen',
      builder: (context, state) {
        return const RiderHomeScreen();
      },
    ),

    GoRoute(
      path: RouteNames.personalprofile,
      name: 'riderpersonalprofile',
      builder: (context, state) {
        return const RiderPersonalInformationScreen();
      },
    ),

    GoRoute(
      path: RouteNames.riderpaymentinformation,
      name: 'riderpaymentinformation',
      builder: (context, state) {
        return const RiderPaymentMethod();
      },
    ),

    GoRoute(
      path: RouteNames.notification,
      name: 'notification',
      builder: (context, state) {
        return const NotificationSettings();
      },
    ),

    GoRoute(
      path: RouteNames.ridersecurity,
      name: 'ridersecurity',
      builder: (context, state) {
        return const RiderSecuritySettings();
      },
    ),

    GoRoute(
      path: '/requestride',
      builder: (context, state) {
        return const RequestRideScreen();
      },
    ),

    GoRoute(
      path: '/activeride',
      builder: (context, state) {
        final rideId = state.extra as String?;

        if (rideId == null || rideId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No active ride found')),
          );
        }

        return ActiveRideScreen(rideId: rideId);
      },
    ),

    GoRoute(
      path: RouteNames.chatscreen,
      name: 'chatscreen',
      builder: (context, state) {
        final rideId = state.extra as String;

        return ChatScreen(rideId: rideId);
      },
    ),

    // =========================================================
    // DRIVER---WITH CONSISTENT BOTTOM NAV USING SHELLROUTE,INDEXED STACK
    // =========================================================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DriverBottomNav(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.driverhomescreen,
              name: 'driverhome',
              builder: (context, state) {
                return const DriverHomeScreen();
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.driverrides,
              name: 'driverrides',
              builder: (context, state) {
                return const DriverRideHistoryScreen();
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.driverchat,
              name: 'driverearnings',
              builder: (context, state) {
                return const Placeholder();
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.driverprofile,
              name: 'driverprofile',
              builder: (context, state) {
                return const DriverProfileScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
