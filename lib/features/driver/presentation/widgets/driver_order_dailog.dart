import 'dart:async';
import 'package:flutter/material.dart';

class DriverOrderDialogs {
  static Future<bool> confirmDelivered(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change status?"),
          content: const Text("Mark this order as DELIVERED?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, Deliver"),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static Future<void> showDeliverySuccess(BuildContext context) async {
    // Dismiss after 3 seconds automatically
    Timer? t;

    await showDialog<void>(
      context: context,
      barrierDismissible: true, // tap anywhere closes
      builder: (context) {
        t = Timer(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        });

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 10),
                  Text(
                    "Delivery Success!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Order marked as delivered.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // cancel timer if user dismissed early
    t?.cancel();
  }
}
