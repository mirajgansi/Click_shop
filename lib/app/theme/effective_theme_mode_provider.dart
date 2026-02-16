import 'package:click_shop/app/theme/light_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_mode_provider.dart';

final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final selected = ref.watch(appThemeModeProvider);

  switch (selected) {
    case AppThemeMode.system:
      return ThemeMode.system;
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.sensor:
      final luxAsync = ref.watch(luxProvider);
      final lux = luxAsync.value ?? 100;
      return lux < 100 ? ThemeMode.dark : ThemeMode.light;
  }
});
