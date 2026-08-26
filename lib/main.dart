import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_shell.dart';
import 'screens/about_screen.dart';
import 'screens/products_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';

void main() => runApp(const ZunixeApp());

class ZunixeApp extends StatelessWidget {
  const ZunixeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'zunixe.com',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Ubuntu',
          primaryColor: const Color(0xFFC8102E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFC8102E),
            primary: const Color(0xFFC8102E),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF3C3C3C),
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainShell(),
          '/about': (context) => const AboutScreen(),
          '/products-full': (context) => const ProductsScreen(isTab: false),
          '/product-detail': (context) => const ProductDetailScreen(),
          '/cart': (context) => CartScreen(onSwitchToProduk: () => Navigator.pop(context)),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
