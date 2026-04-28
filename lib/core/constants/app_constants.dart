class AppConstants {
  AppConstants._();

  // SharedPreferences keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String kSessionKey = 'session_user_id';
  static const String kUserEmailKey = 'session_user_email';

  // Route names
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeMain = '/main';
  static const String routeCatalog = 'catalog';
  static const String routeProductDetail = 'product/:id';
  static const String routeCart = 'cart';
  static const String routeOrders = 'orders';
  static const String routeAnalytics = 'analytics';

  // UI
  static const String appName = 'MolokoAyran';

  // Validation
  static const int kMinPasswordLength = 6;
}
