class AppConstants {
  AppConstants._();

  // SharedPreferences keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String kSessionKey = 'session_user_id';
  static const String kUserEmailKey = 'session_user_email';
  static const String kThemeKey = 'theme_mode';
  static const String kOnboardingCompletedKey = 'onboarding_completed';

  // Route names
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeMain = '/main';
  static const String routeCatalog = 'catalog';
  static const String routeProductDetail = 'product/:id';
  static const String routeCart = 'cart';
  static const String routeOrders = 'orders';
  static const String routeAnalytics = 'analytics';
  static const String routeProfile = '/profile';

  // UI
  static const String appName = 'MolokoAyran';

  // Validation
  static const int kMinPasswordLength = 6;
}
