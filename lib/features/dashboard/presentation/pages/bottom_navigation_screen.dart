import 'package:click_shop/core/providers/socket_service_provider.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/explore_screen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/cart_sreen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/my_order_screen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';
import 'package:click_shop/features/dashboard/presentation/pages/notification_page.dart';
import 'package:click_shop/features/dashboard/presentation/providers/notification_settings_provider.dart';
import 'package:click_shop/features/dashboard/presentation/view_model/notification_view_model.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_notification_banner.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/favriout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Home",
    "Explore",
    "My Cart",
    "My Orders",
    "Favorites",
    "Account",
  ];

  final List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const ExploreScreen(),
    const CartScreen(),
    const MyOrdersPage(),
    const FavoriteProductsScreen(),
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

  late final ProviderSubscription<AsyncValue<dynamic>> _sub;

  @override
  void initState() {
    super.initState();

    _sub = ref.listenManual<AsyncValue<dynamic>>(
      socketNotificationStreamProvider,
      (prev, next) {
        next.whenData((data) {
          // If this widget is gone, do nothing
          if (!mounted) return;

          // update state
          ref
              .read(notificationViewModelProvider.notifier)
              .onSocketNotification(data);

          final enabled = ref.read(notificationEnabledProvider);

          // show toast only when OFF
          if (!enabled) {
            final title = (data is Map && data['title'] != null)
                ? data['title'].toString()
                : "New notification";

            final msg = (data is Map && data['message'] != null)
                ? data['message'].toString()
                : "";

            InAppNotification.showGlobal(title: title, message: msg);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
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
            Image.asset('assets/images/happy.png', width: 40, height: 40),
            const SizedBox(width: 10),
            Text(
              [
                "Home",
                "Explore",
                "My Cart",
                "My Orders",
                "Favorites",
                "Account",
              ][_selectedIndex],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          // ❤️ FAVORITES BUTTON
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteProductsScreen(),
                ),
              );
            },
          ),

          Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(notificationViewModelProvider);

              return IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );

                  if (!mounted) return;

                  ref
                      .read(notificationViewModelProvider.notifier)
                      .loadUnreadCount();
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    if (state.unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "${state.unreadCount}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: [
        const HomeScreen(),
        const ExploreScreen(),
        const CartScreen(),
        const MyOrdersPage(),
        const FavoriteProductsScreen(),
        const ProfileScreen(),
      ][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withOpacity(0.6),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          _svgNavItem(
            asset: 'assets/icons/home.svg',
            label: 'Home',
            index: 0,
            color: _selectedIndex == 0 ? const Color(0xFF53B175) : Colors.black,
          ),
          _svgNavItem(
            asset: 'assets/icons/explore.svg',
            label: 'Explore',
            index: 1,
            color: _selectedIndex == 1 ? const Color(0xFF53B175) : Colors.black,
          ),
          _svgNavItem(
            asset: 'assets/icons/cart.svg',
            label: 'Cart',
            index: 2,
            color: _selectedIndex == 2 ? const Color(0xFF53B175) : Colors.black,
          ),
          _svgNavItem(
            asset: 'assets/icons/delivery.svg',
            label: 'Order',
            index: 3,
            color: _selectedIndex == 3 ? const Color(0xFF53B175) : Colors.black,
          ),
          _svgNavItem(
            asset: 'assets/icons/heart.svg',
            label: 'Fav',
            index: 4,
            color: _selectedIndex == 4 ? const Color(0xFF53B175) : Colors.black,
          ),
          _svgNavItem(
            asset: 'assets/icons/account.svg',
            label: 'Account',
            index: 5,
            color: _selectedIndex == 5 ? const Color(0xFF53B175) : Colors.black,
          ),
        ],
      ),
    );
  }
}
