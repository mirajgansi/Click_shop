import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class ProximitySensorWidget extends StatefulWidget {
  final Future<void> Function() onNear;
  final bool enabled;
  final Duration cooldown;
  final Widget child;

  const ProximitySensorWidget({
    super.key,
    required this.onNear,
    required this.child,
    this.enabled = true,
    this.cooldown = const Duration(seconds: 2),
  });

  @override
  State<ProximitySensorWidget> createState() => _ProximitySensorWidgetState();
}

class _ProximitySensorWidgetState extends State<ProximitySensorWidget> {
  StreamSubscription<int>? _sub;
  bool _busy = false;
  bool _cooldownActive = false;

  @override
  void initState() {
    super.initState();

    _sub = ProximitySensor.events.listen((event) async {
      if (!widget.enabled) return;
      if (_busy || _cooldownActive) return;

      final isNear = event == 0; // usually 0=near, 1=far
      if (!isNear) return;

      _busy = true;
      _cooldownActive = true;

      try {
        await widget.onNear();
      } finally {
        _busy = false;
        Future.delayed(widget.cooldown, () {
          _cooldownActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
