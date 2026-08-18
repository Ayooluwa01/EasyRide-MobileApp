import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends Notifier {
  @override
  build() {
    return true;
  }

  void setCompleted() {
    state = false;
  }
}

final SettingsProvider = NotifierProvider(SettingsNotifier.new);
