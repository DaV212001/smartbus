import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:smartbus/screens/alerts_screen.dart';
import 'package:smartbus/screens/home_screen.dart';
import 'package:smartbus/screens/ticket_screen.dart';
import 'package:smartbus/screens/wallet_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const TicketScreen(),
      const WalletScreen(),
      const AlertsScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(LucideIcons.map),
        title: ("Routes"),
        activeColorPrimary: Theme.of(context).primaryColor,
        inactiveColorPrimary: const Color(0xFF64748B),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(LucideIcons.qrCode),
        title: ("My Ticket"),
        activeColorPrimary: Theme.of(context).primaryColor,
        inactiveColorPrimary: const Color(0xFF64748B),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(LucideIcons.wallet),
        title: ("Wallet"),
        activeColorPrimary: Theme.of(context).primaryColor,
        inactiveColorPrimary: const Color(0xFF64748B),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(LucideIcons.bell),
        title: ("Alerts"),
        activeColorPrimary: Theme.of(context).primaryColor,
        inactiveColorPrimary: const Color(0xFF64748B),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      navBarHeight: 80,
      screens: _buildScreens(),
      items: _navBarsItems(context),
      confineToSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      handleAndroidBackButtonPress: true,
      // resizeToAvoidBottomInset: true,
      stateManagement: true,
      padding: const EdgeInsets.all(16),
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(0.0),
        colorBehindNavBar: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
      ),
      // popAllScreensOnTapOfSelectedTab: true,
      // popActionScreens: PopActionScreensType.all,
      // itemAnimationProperties: const ItemAnimationProperties(
      //   duration: Duration(milliseconds: 200),
      //   curve: Curves.ease,
      // ),
      // screenTransitionProperties: const ScreenTransitionProperties(
      //   animateTabTransition: true,
      //   curve: Curves.ease,
      //   duration: Duration(milliseconds: 200),
      // ),
      navBarStyle: NavBarStyle.style6, // Choose the nav bar style!
    );
  }
}
