import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MolokoAyranApp());
}

class MolokoAyranApp extends StatelessWidget {
  const MolokoAyranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MolokoAyran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32), // зелёный — природа, ферма
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routerConfig: appRouter,
    );
  }
}
