import 'package:click_shop/widgets/my_button_widgets.dart';
import 'package:click_shop/widgets/my_menu_items_widgets.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  'assets/images/profile_picture.png',
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),

                      Icon(Icons.edit, size: 16, color: Colors.grey),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey),

                      Text(
                        'JohnDoe@gmail.com',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
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
          const MyMenuItemsWidgets(icon: Icons.info_outline, title: 'About'),
          SizedBox(height: 25),
          MyButtonWidgets(
            text: 'Log  Out',
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
