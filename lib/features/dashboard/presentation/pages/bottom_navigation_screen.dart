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
import 'package:click_shop/features/dashboard/presentation/pages/favriout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ExploreScreen(),
    CartScreen(),
    MyOrdersPage(),
    ProfileScreen(),
  ];

  final List<String> _titles = const [
    "Home",
    "Explore",
    "My Cart",
    "My Orders",
    "Account",
  ];

  late final ProviderSubscription<AsyncValue<dynamic>> _sub;

  @override
  void initState() {
    super.initState();

    // ✅ load unread count when dashboard is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationViewModelProvider.notifier).loadUnreadCount();
      ref.read(notificationViewModelProvider.notifier).load(); // optional
    });

    _sub = ref.listenManual<AsyncValue<dynamic>>(
      socketNotificationStreamProvider,
      (prev, next) {
        next.whenData((data) {
          if (!mounted) return;

          ref
              .read(notificationViewModelProvider.notifier)
              .onSocketNotification(data);

          final enabled = ref.read(notificationEnabledProvider);
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

  void _goTo(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _navItem({
    required String asset,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _goTo(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                asset,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isActive ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final active = cs.primary; // or const Color(0xFF53B175)
    final inactive = cs.onSurface.withOpacity(0.65);

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
              _titles[_selectedIndex],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        actions: [
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

      // keeps state if you switch tabs often
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // CART IN CENTER
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 62,
        width: 62,
        child: FloatingActionButton(
          elevation: 6,
          backgroundColor: active,
          onPressed: () => _goTo(2), // cart page index
          shape: const CircleBorder(),
          child: SvgPicture.asset(
            'assets/icons/cart.svg',
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: cs.surface,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _navItem(
                asset: 'assets/icons/home.svg',
                label: 'Home',
                index: 0,
                activeColor: active,
                inactiveColor: inactive,
              ),
              _navItem(
                asset: 'assets/icons/explore.svg',
                label: 'Explore',
                index: 1,
                activeColor: active,
                inactiveColor: inactive,
              ),

              // space for the center FAB notch
              const SizedBox(width: 62),

              _navItem(
                asset: 'assets/icons/delivery.svg',
                label: 'Order',
                index: 3,
                activeColor: active,
                inactiveColor: inactive,
              ),
              // _navItem(
              //   asset: 'assets/icons/heart.svg',
              //   label: 'Fav',
              //   index: 4,
              //   activeColor: active,
              //   inactiveColor: inactive,
              // ),
              _navItem(
                asset: 'assets/icons/account.svg',
                label: 'Account',
                index: 4,
                activeColor: active,
                inactiveColor: inactive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
