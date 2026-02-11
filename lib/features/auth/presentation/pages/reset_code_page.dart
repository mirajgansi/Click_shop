import 'package:click_shop/features/auth/presentation/pages/reset_new_password_page.dart';
import 'package:click_shop/features/auth/presentation/widgets/otp_widgets.dart';
import 'package:flutter/material.dart';

class ResetCodePage extends StatefulWidget {
  final String? initialEmail;

  const ResetCodePage({super.key, this.initialEmail});

  @override
  State<ResetCodePage> createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  String _code = "";

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail ?? "";
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    if (!RegExp(r'^\d{6}$').hasMatch(_code)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Code must be 6 digits")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResetNewPasswordPage(email: _emailCtrl.text.trim(), code: _code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 22,
                  color: Colors.black12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Verify code",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Enter the 6-digit code sent to your email.",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "you@example.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    validator: (v) {
                      final s = (v ?? "").trim();
                      if (s.isEmpty) return "Email is required";
                      final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);
                      if (!ok) return "Invalid email";
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Reset code",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  OtpInput(length: 6, onChanged: (v) => _code = v),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Code expires in 10 minutes.",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _next,
                      child: const Text("Next"),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Resend code"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
