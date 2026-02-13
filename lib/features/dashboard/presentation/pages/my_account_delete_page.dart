import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final authState = ref.watch(AuthViewModelProvider);
    final vm = ref.read(AuthViewModelProvider.notifier);

    final user = authState.user;
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0.5,
        title: Text(
          "Delete my account",
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile row
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? "Your name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? "",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: cs.onSurface.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Text(
                "Confirm your password",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Complete the delete process by entering the password associated with your account.",
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 14),

              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.45)),
                    filled: true,
                    fillColor: cs.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.6),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: cs.primary, width: 1.4),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "Password is required";
                    if (v.trim().length < 6)
                      return "Password must be at least 6 characters";
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              if (authState.status == AuthStatus.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    authState.errorMessage ?? "Something went wrong",
                    style: TextStyle(
                      color: cs.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.error, // ✅ theme error (red)
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!(_formKey.currentState?.validate() ?? false))
                            return;

                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: cs.surface,
                              title: Text(
                                "Delete account?",
                                style: TextStyle(color: cs.onSurface),
                              ),
                              content: Text(
                                "This action is permanent and cannot be undone.",
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.75),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: cs.error,
                                  ),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );

                          if (ok != true) return;

                          await vm.deleteMeWithPassword(
                            _passwordController.text.trim(),
                          );

                          if (!context.mounted) return;

                          final newState = ref.read(AuthViewModelProvider);
                          if (newState.status != AuthStatus.error) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                  child: Text(isLoading ? "Deleting..." : "Delete account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
