import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CheckoutButton extends StatefulWidget {
  final VoidCallback onCheckout;
  final double total;

  const CheckoutButton({
    super.key,
    required this.onCheckout,
    required this.total,
  });

  @override
  State<CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
  StreamSubscription? _accelerometerSub;
  double _lastX = 0, _lastY = 0, _lastZ = 0;
  int _lastShakeTime = 0;

  @override
  void initState() {
    super.initState();

    _accelerometerSub = accelerometerEvents.listen((event) {
      final x = event.x;
      final y = event.y;
      final z = event.z;

      final deltaX = (x - _lastX).abs();
      final deltaY = (y - _lastY).abs();
      final deltaZ = (z - _lastZ).abs();

      _lastX = x;
      _lastY = y;
      _lastZ = z;

      const shakeThreshold = 15.0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if ((deltaX > shakeThreshold ||
              deltaY > shakeThreshold ||
              deltaZ > shakeThreshold) &&
          (currentTime - _lastShakeTime > 1000)) {
        _lastShakeTime = currentTime;
        widget.onCheckout();
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final double maxWidth = isTablet ? 520 : double.infinity;
    final double height = isTablet ? 64 : 56;

    final double titleSize = isTablet ? 16 : 14;
    final double priceSize = isTablet ? 15 : 14;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: widget.onCheckout,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Go to\nCheckout",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "Rs.${widget.total.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: priceSize,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
