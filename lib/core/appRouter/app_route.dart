import 'package:amazon_clone/splash.dart';
import 'package:amazon_clone/views/auth/login_screen.dart';
import 'package:amazon_clone/views/auth/signup_screen.dart';
import 'package:amazon_clone/views/cart/cart_screen.dart';
import 'package:amazon_clone/views/cart/checkout/orders_screen.dart';
import 'package:amazon_clone/views/category/category_screen.dart';
import 'package:amazon_clone/views/home/home_screen.dart';
import 'package:amazon_clone/views/main_screen.dart' show MainScreen;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/main', builder: (context, state) => MainScreen()),
      GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
      GoRoute(path: '/orders', builder: (context, state) => OrdersScreen()),
      GoRoute(path: '/category', builder: (context, state) => CategoryScreen()),
    ],
  );
});
