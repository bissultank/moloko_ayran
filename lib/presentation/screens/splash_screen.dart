import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../blocs/auth/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingThenSession();
  }

  Future<void> _checkOnboardingThenSession() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final completed =
        prefs.getBool(AppConstants.kOnboardingCompletedKey) ?? false;

    if (!completed) {
      if (mounted) context.go(AppConstants.routeOnboarding);
      return;
    }

    setState(() => _onboardingChecked = true);
    if (mounted) {
      context.read<AuthBloc>().add(const AuthCheckSessionRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!_onboardingChecked) return;
        if (state is AuthAuthenticated) {
          context.go('/${AppConstants.routeCatalog}');
        } else if (state is AuthUnauthenticated || state is AuthError) {
          context.go(AppConstants.routeLogin);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop_rounded,
                  size: 80, color: Theme.of(context).colorScheme.onPrimary),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Натуральные продукты от фермеров',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.8),
                    ),
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
