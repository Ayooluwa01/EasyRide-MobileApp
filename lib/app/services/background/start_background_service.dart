import 'package:flutter_background_service/flutter_background_service.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();

  service.startService();
}
