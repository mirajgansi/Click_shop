import 'package:click_shop/widgets/my_button_widgets.dart';
import 'package:click_shop/widgets/my_menu_items_widgets.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: fontName,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: spacingH / 2),
                          Icon(Icons.edit, size: iconSize, color: Colors.grey),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: iconSize, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'JohnDoe@gmail.com',
                            style: TextStyle(
                              fontSize: fontEmail,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                height: 90,
                child: MyButtonWidgets(
                  text: 'Log Out',
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
