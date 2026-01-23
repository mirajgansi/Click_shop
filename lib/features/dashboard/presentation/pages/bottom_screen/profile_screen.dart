import 'dart:io';

import 'package:click_shop/app/theme/theme_extensions.dart';
import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_menu_items_widgets.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

final currentUserProvider = FutureProvider<Either<Failure, AuthEntity>>((ref) {
  final usecase = ref.read(getCurrentUserUsecaseProvider);
  return usecase();
});

class ProfileScreen extends ConsumerWidget {
  ProfileScreen({super.key});

  //camera permission
  final List<XFile> _selectedMedia =
      []; //images video all not suitable for this page
  final ImagePicker _picker = ImagePicker();

  Future<bool> _userSagaPermissionMagana(
    BuildContext context,
    Permission permission,
  ) async {
    final permissionStatus = await permission.status;
    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    } else if (permissionStatus.isPermanentlyDenied) {
      _showPermissionDeniedDailog(context);
      return false;
    }
    return false;
  }

  void _showPermissionDeniedDailog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Give Permission"),
        content: Text(
          "Yo feature haru use garna lai permission settings ma janu hola",
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text("cancel")),
          TextButton(onPressed: () {}, child: const Text("Open Settings")),
        ],
      ),
    );
  }

  //code for camera
  Future<void> _pickCamera(BuildContext context) async {
    final hasPermission = await _userSagaPermissionMagana(
      context,
      Permission.camera,
    );
    if (!hasPermission) return;

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, //size ghatxa but quality ramro hunxa
    );
    if (photo != null) {
      setState() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      }
    }
  }

  // code for video
  Future<void> _pickVideo(BuildContext context) async {
    final hasPermission = await _userSagaPermissionMagana(
      context,
      Permission.camera,
    );

    if (!hasPermission) return;

    final hasMicPermission = await _userSagaPermissionMagana(
      context,
      Permission.microphone,
    );
    if (!hasMicPermission) return;

    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 60),
    );
    if (video != null) {
      setState() {
        _selectedMedia.clear();
        _selectedMedia.add(video);
      }
    }
  }

  // code for gallery for single image
  Future<void> _pickGallery(
    BuildContext context, {
    bool allowMultiple = false,
  }) async {
    final hasPermission = await _userSagaPermissionMagana(
      context,
      Permission.photos,
    );
    if (!hasPermission) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState() {
        _selectedMedia.clear();
        _selectedMedia.add(image);
      }
    }
  }

  //code for gallery for multiple images
  // Future<void> _pickGallery(
  //   BuildContext context, {
  //   bool allowMultiple = false,
  // }) async {
  //   try {
  //     if (allowMultiple) {
  //       final List<XFile>? images = await _picker.pickMultiImage(
  //         imageQuality: 80,
  //       );
  //       if (images != null && images.isNotEmpty) {
  //         setState() {
  //           _selectedMedia.clear();
  //           _selectedMedia.addAll(images);
  //         }
  //       }
  //     } else {
  //       final XFile? image = await _picker.pickImage(
  //         source: ImageSource.gallery,
  //         imageQuality: 80,
  //       );
  //       if (image != null) {
  //         setState() {
  //           _selectedMedia.clear();
  //           _selectedMedia.add(image);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("error in multiple image selection: $e");
  //     if (context.mounted) {
  //       SnackbarUtils.showError(
  //         context,
  //         "Failed to access images. Please try again.",
  //       );
  //     }
  //   }
  // }

  //code for dailogBox: showDailog for menu
  Future<void> _pickMediaDailog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickCamera(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text("Record Video"),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickGallery(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;

        final double avatarRadius = isTablet ? 40 : 50;
        final double spacingH = isTablet ? 12 : 16;
        final double fontName = isTablet ? 18 : 22;
        final double fontEmail = isTablet ? 14 : 16;
        final double iconSize = isTablet ? 14 : 16;
        final double dividerThickness = isTablet ? 1 : 1.5;

        //Menu items controllers and variables
        final _usernameController = TextEditingController();
        final _emailController = TextEditingController();
        final _passwordController = TextEditingController();
        final _confirmPasswordController = TextEditingController();
        final _locationController = TextEditingController();

        bool notificationsEnabled = true;

        bool _obscurePassword = true;
        bool _obscureConfirmPassword = true;
        bool _agreedToTerms = false;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickMediaDailog(context);
                    },
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: const AssetImage(
                        'assets/images/Group.jpg',
                      ),
                    ),
                  ),

                  SizedBox(width: spacingH),
                  currentUserAsync.when(
                    loading: () => const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (e, st) => const Text("Failed to load user"),
                    data: (either) => either.fold(
                      (failure) => Text("Failed: ${failure.toString()}"),
                      (user) {
                        final name = user.username ?? "No name";
                        final email = user.email;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: fontName,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: spacingH / 2),
                                Icon(
                                  Icons.edit,
                                  size: iconSize,
                                  color: Colors.grey,
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  size: iconSize,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: fontEmail,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              Divider(thickness: dividerThickness, height: 32),

              // const MyMenuItemsWidgets(
              //   icon: Icons.shopping_bag_outlined,
              //   title: 'Order',
              // ),
              MyMenuItemsWidgets(
                icon: Icons.person,
                title: "My Details",
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // call your update API here
                      // nameController.text, emailController.text
                    },
                    child: const Text("Update"),
                  ),
                ],
              ),

              MyMenuItemsWidgets(
                icon: Icons.location_on_outlined,
                title: 'Delivery address',
                children: [
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                ],
              ),
              MyMenuItemsWidgets(
                icon: Icons.notifications,
                title: "Notifications",
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Enable Notifications"),
                    value: notificationsEnabled,
                    onChanged: (val) {
                      // setState(() => notificationsEnabled = val);
                      // Save to backend/sharedPreferences if needed
                    },
                  ),
                ],
              ),
              const MyMenuItemsWidgets(icon: Icons.help_outline, title: 'Help'),
              const MyMenuItemsWidgets(
                icon: Icons.info_outline,
                title: 'About',
              ),

              SizedBox(height: 25),
              SizedBox(height: 24),
              if (_selectedMedia.isNotEmpty) ...[
                Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_selectedMedia[0].path)),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState() {
                        _selectedMedia.clear();
                      }
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
              Text(
                'Item name',
                style: TextStyle(
                  fontSize: fontName,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: MyButtonWidgets(
                  text: 'Log Out',
                  onPressed: () async {
                    await ref.read(UserSessionServiceProvider).logout();

                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  height: 12,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
