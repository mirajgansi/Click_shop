import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';

final luxProvider = StreamProvider<int>((ref) {
  return LightSensor.luxStream();
});

final autoThemeModeProvider = Provider<ThemeMode>((ref) {
  final luxAsync = ref.watch(luxProvider);

  final lux = luxAsync.value ?? 100;

  return lux < 200 ? ThemeMode.dark : ThemeMode.light;
});
