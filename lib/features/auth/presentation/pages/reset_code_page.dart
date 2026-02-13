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
    final cs = Theme.of(context).colorScheme;
    final email = widget.initialEmail ?? _emailCtrl.text;

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 22,
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.18
                        : 0.08,
                  ),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verify code",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.75),
                      ),
                      children: [
                        const TextSpan(
                          text: "Enter the 6-digit code sent to your ",
                        ),
                        TextSpan(
                          text: email,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    "Reset code",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),

                  OtpInput(length: 6, onChanged: (v) => _code = v),

                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Code expires in 10 minutes.",
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.65),
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _next,
                      child: const Text("Next"),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Resend code",
                        style: TextStyle(color: cs.primary),
                      ),
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
