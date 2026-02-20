import 'package:click_shop/features/auth/presentation/pages/reset_new_password_page.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:click_shop/features/auth/presentation/widgets/otp_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetCodePage extends ConsumerStatefulWidget {
  // ✅
  final String? initialEmail;
  const ResetCodePage({super.key, this.initialEmail});

  @override
  ConsumerState<ResetCodePage> createState() => _ResetCodePageState(); // ✅
}

class _ResetCodePageState extends ConsumerState<ResetCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  String _code = "";
  String? _codeError; // ✅ inline error

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail ?? "";
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();
    final code = _code.trim();

    if (code.isEmpty) {
      setState(() => _codeError = "Code is required");
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _codeError = "Code must be 6 digits");
      return;
    }

    setState(() => _codeError = null);

    // ✅ CALL BACKEND VERIFY
    final ok = await ref
        .read(AuthViewModelProvider.notifier)
        .verifyResetCode(email: email, code: code);

    if (!ok) {
      final msg =
          ref.read(AuthViewModelProvider).errorMessage ?? "Invalid reset code";
      setState(() => _codeError = msg);
      return; // ✅ STOP, DON'T NAVIGATE
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetNewPasswordPage(email: email, code: code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final email = widget.initialEmail ?? _emailCtrl.text;

    return Scaffold(
      backgroundColor: cs.surface,
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

                  OtpInput(
                    length: 6,
                    hasError: _codeError != null,
                    onChanged: (v) {
                      setState(() {
                        _code = v;
                        _codeError = null;
                      });
                    },
                  ),
                  if (_codeError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _codeError!,
                      style: TextStyle(
                        color: cs.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
