import 'dart:async';

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
    _timer = Timer(const Duration(seconds: 3), () {
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
