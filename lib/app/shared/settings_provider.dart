import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends Notifier<bool> {
  // static const String _firstlaunch = 'first_launch';
  @override
  bool build() {
    return true;
  }

  void setCompleted() {
    state = false;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, bool>(
  SettingsNotifier.new,
);
