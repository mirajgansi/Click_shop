import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/explore_screen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/cart_sreen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/my_order_screen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Home",
    "Explore",
    "My Cart",
    "My Orders",
    "Account",
  ];

  final List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const ExploreScreen(),
    const CartScreen(),
    const MyOrdersPage(),
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
      // ✅ Use theme background
      backgroundColor: cs.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        // ✅ Let theme control appbar color
        backgroundColor: cs.surface,
        title: Row(
          children: [
            Image.asset(
              'assets/images/Group.jpg',
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
                color: cs.onSurface, // ✅ dynamic
              ),
            ),
          ],
        ),
      ),

      body: lstBottomScreen[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,

        // ✅ Use theme colors
        backgroundColor: cs.surface,
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
            label: 'Home',
            index: 0,
            color: _selectedIndex == 0
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
          _svgNavItem(
            asset: 'assets/icons/explore.svg',
            label: 'Explore',
            index: 1,
            color: _selectedIndex == 1
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
          _svgNavItem(
            asset: 'assets/icons/cart.svg',
            label: 'Cart',
            index: 2,
            color: _selectedIndex == 2
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
          _svgNavItem(
            asset: 'assets/icons/delivery.svg',
            label: 'Order',
            index: 3,
            color: _selectedIndex == 3
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
          _svgNavItem(
            asset: 'assets/icons/account.svg',
            label: 'Account',
            index: 4,
            color: _selectedIndex == 4
                ? cs.primary
                : cs.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
