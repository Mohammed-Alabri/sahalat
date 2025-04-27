import 'package:flutter/material.dart';
import 'package:sahalat/pages/home_page.dart';
import 'package:sahalat/pages/vendor_selection_page.dart';
import 'package:sahalat/pages/cart_page.dart';
import 'package:sahalat/pages/order_history_page.dart';
import 'package:sahalat/pages/profile_page.dart';
import 'package:sahalat/theme/app_theme.dart';
import 'package:sahalat/services/navigation_service.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  MainLayoutState createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout>
    with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  final _navigationService = NavigationService();
  final _pageController = PageController();
  final _pages = <Widget>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializePages();
  }

  void _initializePages() {
    _pages.addAll([
      const HomePage(),
      const VendorSelectionPage(),
      const CartPage(),
      const OrderHistoryPage(),
      const ProfilePage(),
    ]);
  }

  void switchToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          switchToPage(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: switchToPage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'Vendors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
