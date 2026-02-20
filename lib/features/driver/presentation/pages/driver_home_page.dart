import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';
import 'package:click_shop/features/driver/presentation/pages/bottom_screen/assigned_page.dart';
import 'package:click_shop/features/driver/presentation/pages/bottom_screen/dashboard_page.dart';
import 'package:click_shop/features/driver/presentation/pages/bottom_screen/delivered_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Dashboard",
    "Assigned Orders",
    "Delivered Orders",
    "Account",
  ];

  final List<Widget> lstBottomScreen = [
    const DriverDashboardPage(),
    const AssignedPage(),
    const DeliveredPage(),
    const ProfileScreen(),
  ];

  BottomNavigationBarItem _svgNavItem({
    required String asset,
    required String label,
    required int index,
    required Color color,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        width: 25,
        height: 25,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: cs.surface,
        title: Row(
          children: [
            Image.asset(
              'assets/images/happy.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Text(
              _titles[_selectedIndex],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),

      body: lstBottomScreen[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cs.surface,
        currentIndex: _selectedIndex,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withOpacity(0.6),

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: [
          _svgNavItem(
            asset: 'assets/icons/home.svg',
            label: 'Assigned',
            index: 0,
            color: _selectedIndex == 0
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
          _svgNavItem(
            asset: 'assets/icons/ic--round-inventory-2.svg',
            label: 'Assigned',
            index: 1,
            color: _selectedIndex == 1
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
          _svgNavItem(
            asset: 'assets/icons/delivery.svg',
            label: 'Delivered',
            index: 2,
            color: _selectedIndex == 2
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
          _svgNavItem(
            asset: 'assets/icons/account.svg',
            label: 'Account',
            index: 3,
            color: _selectedIndex == 3
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
