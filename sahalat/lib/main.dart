import 'package:flutter/material.dart';
import 'package:sahalat/pages/main_layout.dart';
import 'package:sahalat/pages/login_page.dart';
import 'package:sahalat/services/auth_service.dart';
import 'package:sahalat/theme/app_theme.dart';
import 'package:sahalat/services/navigation_service.dart';
import 'package:sahalat/pages/restaurant_details_page.dart';
import 'package:sahalat/pages/product_details_page.dart';
import 'package:sahalat/pages/checkout_page.dart';
import 'package:sahalat/pages/order_tracking_page.dart';
import 'package:sahalat/models/restaurant.dart';
import 'package:sahalat/models/product.dart';
import 'package:sahalat/pages/add_address_page.dart';
import 'package:sahalat/pages/edit_address_page.dart';
import 'package:sahalat/services/address_service.dart';
import 'package:sahalat/pages/payment_methods_page.dart';
import 'package:sahalat/pages/add_card_page.dart';
import 'package:sahalat/pages/add_bank_page.dart';
import 'package:sahalat/services/payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PaymentService.initialize(); // Clear any saved payment methods
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahalat',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey,
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          primary: AppTheme.primaryColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/add-address': (context) => const AddAddressPage(),
        '/payment-methods': (context) => const PaymentMethodsPage(),
        '/add-card': (context) => const AddCardPage(),
        '/add-bank': (context) => const AddBankPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (_) => const AuthenticationWrapper());
          case '/main':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => MainLayout(
                initialIndex: args?['initialIndex'] ?? 0,
              ),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginPage(
                onLoginSuccess: () {
                  NavigationService().navigateToReplacement('/main');
                },
              ),
            );
          case '/restaurant-details':
            final restaurant = settings.arguments as Restaurant;
            return MaterialPageRoute(
              builder: (_) => RestaurantDetailsPage(restaurant: restaurant),
            );
          case '/product-details':
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailsPage(
                id: product.id,
                name: product.name,
                description: product.description,
                price: product.price,
                restaurantId: product.restaurantId,
                restaurantName: product.restaurantName,
              ),
            );
          case '/checkout':
            return MaterialPageRoute(builder: (_) => const CheckoutPage());
          case '/order-tracking':
            return MaterialPageRoute(builder: (_) => const OrderTrackingPage());
          case '/edit-address':
            final address = settings.arguments as DeliveryAddress;
            return MaterialPageRoute(
              builder: (_) => EditAddressPage(address: address),
            );
          default:
            return MaterialPageRoute(
                builder: (_) => const AuthenticationWrapper());
        }
      },
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isAuthenticated = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const MainLayout();
    }

    return LoginPage(
      onLoginSuccess: () {
        setState(() {
          _isAuthenticated = true;
        });
      },
    );
  }
}
