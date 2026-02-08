import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_text_field_widgets.dart';

class MyDetailsScreen extends ConsumerStatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  ConsumerState<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends ConsumerState<MyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController locationController;
  late final TextEditingController genderController;
  late final TextEditingController dobController;

  bool _filledOnce = false;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    locationController = TextEditingController();
    genderController = TextEditingController();
    dobController = TextEditingController();

    // ✅ Trigger loading current user (Hive / API) after screen opens
    Future.microtask(() {
      ref.read(AuthViewModelProvider.notifier).getCurrentUser();
    });
  }

  void _fillControllers(AuthEntity user) {
    usernameController.text = user.username ?? "";
    emailController.text = user.email;
    phoneController.text = user.phoneNumber ?? "";
    locationController.text = user.location ?? "";
    genderController.text = user.gender ?? "";
    dobController.text = user.dob ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(AuthViewModelProvider);
    final vm = ref.read(AuthViewModelProvider.notifier);

    // ✅ When user becomes available, fill once
    final user = authState.user;
    if (user != null && !_filledOnce) {
      _filledOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillControllers(user);
      });
    }

    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text("My Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextFieldWidgets(
                controller: usernameController,
                hintText: "Enter username",
                text: "Username",
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Username required";
                  if (v.trim().length < 3) return "Min 3 characters";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              MyTextFieldWidgets(
                controller: emailController,
                hintText: "Enter email",
                text: "Email",
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Email required";
                  if (!v.contains("@")) return "Invalid email";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              MyTextFieldWidgets(
                controller: phoneController,
                hintText: "Enter phone number",
                text: "Phone Number",
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (v.trim().length < 7) return "Invalid phone number";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              MyTextFieldWidgets(
                controller: locationController,
                hintText: "Enter location",
                text: "Location",
                validator: (_) => null,
              ),
              const SizedBox(height: 12),

              MyTextFieldWidgets(
                controller: genderController,
                hintText: "Male / Female / Other",
                text: "Gender",
                validator: (_) => null,
              ),
              const SizedBox(height: 12),

              MyTextFieldWidgets(
                controller: dobController,
                hintText: "YYYY-MM-DD",
                text: "Date of Birth",
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v.trim())) {
                    return "Use YYYY-MM-DD";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (authState.status == AuthStatus.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    authState.errorMessage ?? "Something went wrong",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: MyButtonWidgets(
                  text: isLoading ? "Updating..." : "Update",
                  height: 50,
                  borderRadius: 12,
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          final current = authState.user;
                          if (current == null) return;

                          final updated = AuthEntity(
                            userId: current.userId,
                            email: emailController.text.trim(),
                            username: usernameController.text.trim(),
                            image: current.image,
                            phoneNumber: phoneController.text.trim().isEmpty
                                ? null
                                : phoneController.text.trim(),
                            location: locationController.text.trim().isEmpty
                                ? null
                                : locationController.text.trim(),
                            gender: genderController.text.trim().isEmpty
                                ? null
                                : genderController.text.trim(),
                            dob: dobController.text.trim().isEmpty
                                ? null
                                : dobController.text.trim(),
                            role: current.role,
                          );

                          await vm.updateUser(updated);

                          if (!context.mounted) return;

                          final newState = ref.read(AuthViewModelProvider);
                          if (newState.status != AuthStatus.error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profile updated successfully"),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    genderController.dispose();
    dobController.dispose();
    super.dispose();
  }
}
