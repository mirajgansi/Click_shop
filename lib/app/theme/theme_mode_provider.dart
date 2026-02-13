import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = "theme_mode";

  @override
  ThemeMode build() {
    final prefs = ref.read(SharedPreferencesProvider);
    final v = prefs.getInt(_key) ?? 0;
    return ThemeMode.values[v.clamp(0, 2)];
  }

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(SharedPreferencesProvider).setInt(_key, mode.index);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
