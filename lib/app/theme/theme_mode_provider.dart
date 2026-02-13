import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { system, light, dark, sensor }

class AppThemeModeNotifier extends Notifier<AppThemeMode> {
  static const _key = "app_theme_mode";
  @override
  AppThemeMode build() {
    final prefs = ref.read(SharedPreferencesProvider);
    final v = prefs.getInt(_key) ?? 0;
    final idx = v.clamp(0, AppThemeMode.values.length - 1);
    return AppThemeMode.values[idx];
  }

  void setMode(AppThemeMode mode) {
    state = mode;
    ref.read(SharedPreferencesProvider).setInt(_key, mode.index);
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, AppThemeMode>(
      AppThemeModeNotifier.new,
    );
