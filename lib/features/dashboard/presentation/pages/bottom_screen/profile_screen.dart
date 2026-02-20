import 'dart:io';

import 'package:click_shop/app/theme/theme_extensions.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/dashboard/presentation/pages/my_account_delete_page.dart';
import 'package:click_shop/features/dashboard/presentation/pages/my_detail_page.dart';
import 'package:click_shop/features/dashboard/presentation/pages/notifcation_setting_page.dart';
import 'package:click_shop/features/dashboard/presentation/pages/theme_setting_page.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_menu_items_widgets.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

final currentUserViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  //camera permission
  final List<XFile> _selectedMedia =
      []; //images video all not suitable for this page
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(currentUserViewModelProvider.notifier).getCurrentUser();
    });
  }

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
        content: const Text(
          "Permission permanently denied. Please enable it from App Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
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

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, //size ghatxa but quality ramro hunxa
    );
    if (image != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(image);
      });

      //upload imge from server
      await ref
          .read(currentUserViewModelProvider.notifier)
          .updateProfile(File(image.path));
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
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(video);
      });
    }
  }

  // code for gallery for single image
  Future<void> _pickGallery(BuildContext context) async {
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
      setState(() {
        debugPrint("Picked: ${image.path}");

        _selectedMedia.clear();
        _selectedMedia.add(image);
      });
      await ref
          .read(currentUserViewModelProvider.notifier)
          .updateProfile(File(image.path));
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
  //         setState?(() {
  //           _selectedMedia.clear();
  //           _selectedMedia.add(image);
  //         });
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
              // ListTile(
              //   leading: Icon(Icons.video_library),
              //   title: Text("Record Video"),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _pickVideo(context);
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickGallery(context);
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.settings),
              //   title: Text("Settings"),
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final authState = ref.watch(currentUserViewModelProvider);

    if (authState.status == AuthStatus.error) {
      return Center(
        child: Text(
          authState.errorMessage ?? 'An unexpected error occurred',
          style: TextStyle(color: cs.error),
        ),
      );
    }
    final user = authState.user;
    if (user == null) {
      return Center(
        child: Text(
          "User not available yet",
          style: TextStyle(color: cs.onSurface),
        ),
      );
    }

    final name = user.username ?? "No name";
    final email = user.email;
    final imagePath = user.image; // "/uploads/....jpg"
    final imageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? "${ApiEndpoints.getHostUrl()}$imagePath"
        : null;

    debugPrint("FINAL IMAGE URL: $imageUrl");
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

        bool notificationsEnabled = true;

        return Container(
          color: cs.surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _pickMediaDailog(context),
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: _selectedMedia.isNotEmpty
                            ? FileImage(File(_selectedMedia.first.path))
                            : (imageUrl != null
                                  ? NetworkImage(imageUrl)
                                  : const AssetImage('assets/images/happy.png')
                                        as ImageProvider),
                      ),
                    ),

                    SizedBox(width: spacingH),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: fontName,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(width: spacingH / 2),
                              Icon(
                                Icons.edit,
                                size: iconSize,
                                color: cs.onSurface.withOpacity(0.55),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: iconSize,
                                color: cs.onSurface.withOpacity(0.55),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: fontEmail,
                                  color: cs.onSurface.withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Divider(
                  thickness: dividerThickness,
                  height: 32,
                  color: cs.outlineVariant.withOpacity(0.6),
                ),
                Column(
                  children: [
                    MyMenuItemWidget(
                      icon: Icons.person,
                      title: "My Details",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyDetailsScreen(),
                          ),
                        );
                      },
                    ),

                    // MyMenuItemWidget(
                    //   icon: Icons.location_on_outlined,
                    //   title: "Delivery address",
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const DeliveryAddressScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    MyMenuItemWidget(
                      icon: Icons.delete_forever_outlined,
                      title: "Delete My Account",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeleteAccountScreen(),
                          ),
                        );
                      },
                    ),
                    MyMenuItemWidget(
                      icon: Icons.dark_mode_outlined,
                      title: "Theme",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ThemeSettingsPage(),
                          ),
                        );
                      },
                    ),
                    MyMenuItemWidget(
                      icon: Icons.notifications,
                      title: "Notifications",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationSettingsPage(),
                          ),
                        );
                      },
                    ),
                    MyMenuItemWidget(
                      icon: Icons.info_outline,
                      title: "About",
                      onTap: () => Navigator.pushNamed(context, "/about"),
                    ),
                  ],
                ),

                SizedBox(height: 200),

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
          ),
        );
      },
    );
  }
}
