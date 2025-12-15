import 'package:click_shop/screens/bottom_screen/explore_screen.dart';
import 'package:click_shop/screens/bottom_screen/favourite_screen.dart';
import 'package:click_shop/screens/bottom_screen/cart_sreen.dart';
import 'package:click_shop/screens/bottom_screen/home_screen.dart';
import 'package:click_shop/screens/bottom_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const ExploreScreen(),
    const CartScreen(),
    const FavouriteScreen(),
    const ProfileScreen(),
  ];

  BottomNavigationBarItem _svgNavItem({
    required String asset,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        width: 25,
        height: 25,
        color: _selectedIndex == index ? const Color(0xFF53B175) : Colors.black,
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/Group.jpg',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF53B175),
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          _svgNavItem(asset: 'assets/icons/home.svg', label: 'Home', index: 0),
          _svgNavItem(
            asset: 'assets/icons/explore.svg',
            label: 'Explore',
            index: 1,
          ),
          _svgNavItem(
            asset: 'assets/icons/cart.svg',
            label: 'Account',
            index: 2,
          ),
          _svgNavItem(
            asset: 'assets/icons/favriout.svg',
            label: 'Account',
            index: 3,
          ),
          _svgNavItem(
            asset: 'assets/icons/profile.svg',
            label: 'Account',
            index: 4,
          ),
        ],
      ),
    );
  }
}
