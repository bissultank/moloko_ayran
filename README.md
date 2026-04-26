# MolokoAyran 🥛

Приложение для заказа натуральных молочных продуктов от фермеров.  
Молоко, айран, курт, сметана, творог и другие продукты — прямо с фермы.

## Стек
- Flutter + Material 3
- BLoC + Equatable
- Drift (SQLite) — офлайн-режим
- GoRouter
- fl_chart

## Экраны
1. SplashScreen — проверка сессии
2. Login / Register — авторизация
3. CatalogScreen — каталог с поиском и фильтром по категории
4. ProductDetailScreen — карточка товара
5. OrdersScreen — мои заказы
6. AnalyticsScreen — расходы по категориям (fl_chart)

## Запуск
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```