// ignore: file_names
import 'dart:async';

import 'package:easy_ride/app/models/toast_notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppActivityNotifier extends Notifier<bool> {
  Timer? _timer;
  @override
  bool build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return false;
  }

  void startLoading() {
    _timer?.cancel();
    state = true;
    _timer = Timer(const Duration(seconds: 1), () {
      state = false;
    });
  }

  void stopLoading() {
    _timer?.cancel();
    state = false;
  }
}

final appActivityProvider = NotifierProvider<AppActivityNotifier, bool>(
  AppActivityNotifier.new,
);

class AppToastNotifier extends Notifier<ToastData?> {
  Timer? _timer;

  @override
  ToastData? build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return null;
  }

  void showError(String message) => _show(message, ToastType.error);

  void showSuccess(String message) => _show(message, ToastType.success);

  void showInfo(String message) => _show(message, ToastType.info);

  void _show(String message, ToastType type) {
    _timer?.cancel();
    state = ToastData(message: message, type: type);
    _timer = Timer(const Duration(seconds: 6), () {
      state = null;
    });
  }

  void dismiss() {
    _timer?.cancel();
    state = null;
  }
}

final appToastProvider = NotifierProvider<AppToastNotifier, ToastData?>(
  AppToastNotifier.new,
);
