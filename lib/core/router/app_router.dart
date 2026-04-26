import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/catalog/catalog_screen.dart';
import '../../presentation/screens/catalog/product_detail_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeSplash,
  redirect: (BuildContext context, GoRouterState state) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.keyUserId);
    final isLoggedIn = userId != null && userId.isNotEmpty;

    final isSplash = state.matchedLocation == AppConstants.routeSplash;
    final isAuth = state.matchedLocation == AppConstants.routeLogin ||
        state.matchedLocation == AppConstants.routeRegister;

    if (isSplash) return null;
    if (!isLoggedIn && !isAuth) return AppConstants.routeLogin;
    if (isLoggedIn && isAuth) return AppConstants.routeMain;
    return null;
  },
  routes: [
    GoRoute(
      path: AppConstants.routeSplash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppConstants.routeLogin,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppConstants.routeRegister,
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/${AppConstants.routeCatalog}',
          builder: (context, state) => const CatalogScreen(),
          routes: [
            GoRoute(
              path: 'product/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '0';
                return ProductDetailScreen(productId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/${AppConstants.routeOrders}',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/${AppConstants.routeAnalytics}',
          builder: (context, state) => const AnalyticsScreen(),
        ),
      ],
    ),
  ],
);
