import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_state.dart';
import '../view_model/auth_view_model.dart';

class ResetNewPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ResetNewPasswordPage({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<ResetNewPasswordPage> createState() =>
      _ResetNewPasswordPageState();
}

class _ResetNewPasswordPageState extends ConsumerState<ResetNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(AuthViewModelProvider.notifier)
        .resetPassword(
          email: widget.email,
          code: widget.code,
          newPassword: _passCtrl.text,
        );

    final state = ref.read(AuthViewModelProvider);

    if (state.status == AuthStatus.loaded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    } else if (state.status == AuthStatus.error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? "Reset failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(AuthViewModelProvider);
    final loading = state.status == AuthStatus.loading;

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
                    "Set new password",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Create a new password for ${widget.email}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    "New password",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_show,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _show = !_show),
                        icon: Icon(
                          _show ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (v) {
                      final s = v ?? "";
                      if (s.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    "Confirm password",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: !_show,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    validator: (v) {
                      if ((v ?? "") != _passCtrl.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
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
                      onPressed: loading ? null : _submit,
                      child: Text(loading ? "Resetting..." : "Reset password"),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
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
