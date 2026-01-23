import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/auth/domain/usecases/logout_usecase.dart';
import 'package:click_shop/features/auth/presentation/pages/login_page.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/core/widgets/my_menu_items_widgets.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = FutureProvider<Either<Failure, AuthEntity>>((ref) {
  final usecase = ref.read(getCurrentUserUsecaseProvider);
  return usecase();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
        final double logoutHeight = isTablet ? 45 : 55;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: const AssetImage(
                      'assets/images/Group.jpg',
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

              const MyMenuItemsWidgets(
                icon: Icons.shopping_bag_outlined,
                title: 'Order',
              ),
              const MyMenuItemsWidgets(
                icon: Icons.card_travel,
                title: 'My details',
              ),
              const MyMenuItemsWidgets(
                icon: Icons.location_on_outlined,
                title: 'Delivery address',
              ),
              const MyMenuItemsWidgets(
                icon: Icons.notifications_none,
                title: 'Notifications',
              ),
              const MyMenuItemsWidgets(icon: Icons.help_outline, title: 'Help'),
              const MyMenuItemsWidgets(
                icon: Icons.info_outline,
                title: 'About',
              ),

              SizedBox(height: 25),

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
