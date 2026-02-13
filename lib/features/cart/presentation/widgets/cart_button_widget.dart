// import 'dart:async';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flutter/material.dart';

// class _CheckoutButtonState extends State<CheckoutButton> {
//   StreamSubscription? _accelerometerSub;
//   double _lastX = 0, _lastY = 0, _lastZ = 0;
//   int _lastShakeTime = 0;

//   @override
//   void initState() {
//     super.initState();

//     _accelerometerSub = accelerometerEvents.listen((event) {
//       final x = event.x;
//       final y = event.y;
//       final z = event.z;

//       final deltaX = (x - _lastX).abs();
//       final deltaY = (y - _lastY).abs();
//       final deltaZ = (z - _lastZ).abs();

//       _lastX = x;
//       _lastY = y;
//       _lastZ = z;

//       final shakeThreshold = 15;
//       final currentTime = DateTime.now().millisecondsSinceEpoch;

//       if ((deltaX > shakeThreshold ||
//               deltaY > shakeThreshold ||
//               deltaZ > shakeThreshold) &&
//           (currentTime - _lastShakeTime > 1000)) {
//         _lastShakeTime = currentTime;

//         widget.onCheckout();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _accelerometerSub?.cancel();
//     super.dispose();
//   } // ✅ THIS WAS MISSING

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 56,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF4CAF50),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 0,
//         ),
//         onPressed: widget.onCheckout,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Expanded(
//               child: Center(
//                 child: Text(
//                   "Go to\nCheckout",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 14,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.25),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Text(
//                 "Rs.${widget.total}",
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
