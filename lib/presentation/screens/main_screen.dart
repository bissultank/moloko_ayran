import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../blocs/cart/cart_bloc.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/${AppConstants.routeCart}')) return 1;
    if (location.startsWith('/${AppConstants.routeOrders}')) return 2;
    if (location.startsWith('/${AppConstants.routeAnalytics}')) return 3;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/${AppConstants.routeCatalog}');
      case 1:
        context.go('/${AppConstants.routeCart}');
      case 2:
        context.go('/${AppConstants.routeOrders}');
      case 3:
        context.go('/${AppConstants.routeAnalytics}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onTabTapped(context, index),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Каталог',
              ),
              NavigationDestination(
                icon: Badge(
                  label: cartState.totalItems > 0
                      ? Text('${cartState.totalItems}')
                      : null,
                  isLabelVisible: cartState.totalItems > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  label: cartState.totalItems > 0
                      ? Text('${cartState.totalItems}')
                      : null,
                  isLabelVisible: cartState.totalItems > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Корзина',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Заказы',
              ),
              const NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Аналитика',
              ),
            ],
          );
        },
      ),
    );
  }
}
