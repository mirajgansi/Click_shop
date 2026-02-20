import 'dart:io';

import 'package:click_shop/app/theme/app_colors.dart';
import 'package:click_shop/app/theme/theme_extensions.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_text_field_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MyDetailsScreen extends ConsumerStatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  ConsumerState<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends ConsumerState<MyDetailsScreen> {
  // ---------- Media ----------
  final List<XFile> _selectedMedia = [];
  final ImagePicker _picker = ImagePicker();

  // ---------- Form ----------
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController locationController;
  late final TextEditingController genderController;
  late final TextEditingController dobController;

  bool _filledOnce = false;
  final double avatarRadius = 90;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    locationController = TextEditingController();
    genderController = TextEditingController();
    dobController = TextEditingController();

    // ✅ Load user after restart
    Future.microtask(() {
      ref.read(AuthViewModelProvider.notifier).getCurrentUser();
    });
  }

  // ---------- Permission ----------
  Future<bool> _askPermission(
    BuildContext context,
    Permission permission,
  ) async {
    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(context);
      return false;
    }

    return false;
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Give Permission"),
        content: const Text(
          "Permission permanently denied. Please enable it from App Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // ---------- Pickers ----------
  Future<void> _pickCamera(BuildContext context) async {
    final ok = await _askPermission(context, Permission.camera);
    if (!ok) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _selectedMedia
        ..clear()
        ..add(image);
    });

    // ✅ Use same provider you use elsewhere
    await ref
        .read(AuthViewModelProvider.notifier)
        .updateProfile(File(image.path));
  }

  Future<void> _pickGallery(BuildContext context) async {
    final ok = await _askPermission(context, Permission.photos);
    if (!ok) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _selectedMedia
        ..clear()
        ..add(image);
    });

    await ref
        .read(AuthViewModelProvider.notifier)
        .updateProfile(File(image.path));
  }

  Future<void> _pickMediaDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickCamera(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickGallery(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
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

    final user = authState.user;

    // ✅ Fill once when user arrives
    if (user != null && !_filledOnce) {
      _filledOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillControllers(user);
      });
    }

    final imagePath = user?.image; // "/uploads/....jpg"
    final imageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? "${ApiEndpoints.getHostUrl()}$imagePath"
        : null;

    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text("My Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickMediaDialog(context),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,

                      backgroundImage: _selectedMedia.isNotEmpty
                          ? FileImage(File(_selectedMedia.first.path))
                          : (imageUrl != null
                                ? NetworkImage(imageUrl)
                                : const AssetImage('assets/images/happy.png')
                                      as ImageProvider),
                    ),

                    // Camera icon
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

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
                            SnackbarUtils.showSuccess(
                              context,
                              "Profile updated successfully",
                            );
                            Navigator.pop(context);
                          } else {
                            SnackbarUtils.showError(
                              context,
                              newState.errorMessage ?? "Update failed",
                            );
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
