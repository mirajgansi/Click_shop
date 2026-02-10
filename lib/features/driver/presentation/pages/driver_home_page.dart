import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';
import 'package:click_shop/features/driver/presentation/pages/bottom_screen/assigned_page.dart';
import 'package:click_shop/features/driver/presentation/pages/bottom_screen/delivered_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedIndex = 0;

  final List<String> _titles = ["Assigned Orders", "Deliverd Orders", ""];

  final List<Widget> lstBottomScreen = [
    const AssignedPage(),
    const DeliveredPage(),
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
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
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
          _svgNavItem(
            asset: 'assets/icons/home.svg',
            label: 'Assinged',
            index: 0,
          ),

          _svgNavItem(
            asset: 'assets/icons/delivery.svg',
            label: 'Deliverd',
            index: 1,
          ),
          _svgNavItem(
            asset: 'assets/icons/account.svg',
            label: 'Account',
            index: 2,
          ),
        ],
      ),
    );
  }
}
