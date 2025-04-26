import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sahalat/pages/home_page.dart';
import 'package:sahalat/pages/login_page.dart';
import 'package:sahalat/pages/register_page.dart';
import 'package:sahalat/pages/restaurant_list_page.dart';
import 'package:sahalat/pages/profile_page.dart';
import 'package:sahalat/pages/order_history_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahalat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Green color theme
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/restaurants': (context) => const RestaurantListPage(),
        '/profile': (context) => const ProfilePage(),
        '/orders': (context) => const OrderHistoryPage(),
      },
    );
  }
}
