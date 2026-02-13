// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';

// class BiometricSetupPage extends StatefulWidget {
//   final VoidCallback? onSuccess; // call this after successful auth (navigate)
//   const BiometricSetupPage({super.key, this.onSuccess});

//   @override
//   State<BiometricSetupPage> createState() => _BiometricSetupPageState();
// }

// class _BiometricSetupPageState extends State<BiometricSetupPage> {
//   final _auth = LocalAuthentication();
//   bool _loading = false;

//   Future<void> _handleContinue() async {
//     if (_loading) return;

//     setState(() => _loading = true);

//     try {
//       final canCheck = await _auth.canCheckBiometrics;
//       final supported = await _auth.isDeviceSupported();

//       if (!supported || !canCheck) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Biometric is not available on this device.")),
//         );
//         return;
//       }

//       final ok = await _auth.authenticate(
//         localizedReason: "Use your fingerprint to enable biometric login",
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );

//       if (!mounted) return;

//       if (ok) {
//         widget.onSuccess?.call();
//         // Or navigate directly:
//         // Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Authentication cancelled.")),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Biometric error: $e")),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 22),
//           child: Column(
//             children: [
//               const SizedBox(height: 24),

//               const Text(
//                 "Set Your Finger Print",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.black,
//                 ),
//               ),

//               const Spacer(),

//               // Big fingerprint icon (simple, no asset needed)
//               Container(
//                 height: 180,
//                 width: 180,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEAF7EE),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.fingerprint,
//                   size: 110,
//                   color: Color(0xFF4CAF50),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               Text(
//                 "Enable biometric login to access your account faster.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.grey.shade700,
//                   fontSize: 13,
//                   height: 1.4,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const Spacer(),

//               SizedBox(
//                 width: double.infinity,
//                 height: 46,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _handleContinue,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2E7D32),
//                     disabledBackgroundColor: const Color(0xFF2E7D32).withOpacity(0.6),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(999),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: _loading
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                         )
//                       : const Text(
//                           "Continue",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14,
//                           ),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 18),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
