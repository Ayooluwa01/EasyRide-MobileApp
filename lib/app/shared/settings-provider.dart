import 'package:flutter_riverpod/flutter_riverpod.dart';

class settings_notifier extends Notifier {
  // static const String _firstlaunch = 'first_launch';
  @override
  build() {
    return true;
  }

  void setCompleted() {
    state = false;
  }
}

final settingsProvider = NotifierProvider(settings_notifier.new);
