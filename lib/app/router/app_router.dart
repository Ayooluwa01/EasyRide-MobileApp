import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/app/shared/bottom_nav.dart';
import 'package:easy_ride/features/auth/screens/get_started.dart';
import 'package:easy_ride/features/auth/screens/otp_screen.dart';
import 'package:easy_ride/features/auth/screens/signup_screen.dart';
import 'package:easy_ride/features/rider/screens/chat_screen.dart';
import 'package:easy_ride/features/rider/screens/payment_method.dart';
import 'package:easy_ride/features/rider/screens/personal_information_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_chat_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_home_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_notification_screen.dart';
import 'package:easy_ride/features/rider/screens/rider_security_screen.dart';
import 'package:easy_ride/features/splash/splash_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import 'route_names.dart';

const secureStorage = FlutterSecureStorage();

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,

  redirect: (context, state) async {
    final accessToken = await secureStorage.read(key: 'access-token');

    final isAuthenticated = accessToken != null && accessToken.isNotEmpty;

    final location = state.matchedLocation;

    if (isAuthenticated) {
      Websocket().initialize(accessToken);
      if (location == RouteNames.splash ||
          location == RouteNames.login ||
          location == RouteNames.signup ||
          location == RouteNames.otp ||
          location == RouteNames.getstarted) {
        return RouteNames.rider;
      }

      return null;
    }

    if (!isAuthenticated && location == RouteNames.rider) {
      Websocket().dispose();
      return RouteNames.getstarted;
    }

    return null;
  },

  routes: [
    GoRoute(
      path: RouteNames.splash,
      name: 'Splash',
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
      name: 'getStarted',
      builder: (context, state) {
        return const GetStarted();
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
      path: RouteNames.riderpersonalprofile,
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
      path: RouteNames.ridernotification,
      name: 'ridernotification',
      builder: (context, state) {
        return const RiderNotificationSettings();
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
      path: '/rider/chats/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        final chatObject = state.extra as ChatPreview;

        return ChatScreen(chatId: chatId, chat: chatObject);
      },
    ),
  ],
);
