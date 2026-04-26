import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'data/datasources/app_database.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/check_session_usecase.dart';
import 'presentation/blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MolokoAyranApp());
}

class MolokoAyranApp extends StatelessWidget {
  const MolokoAyranApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Собираем зависимости
    final db = AppDatabase.instance;
    final authLocalDatasource = AuthLocalDatasource(db);
    final authRepository = AuthRepositoryImpl(authLocalDatasource);

    return BlocProvider(
      create: (_) => AuthBloc(
        loginUseCase: LoginUseCase(authRepository),
        registerUseCase: RegisterUseCase(authRepository),
        checkSessionUseCase: CheckSessionUseCase(authRepository),
        authRepository: authRepository,
      ),
      child: MaterialApp.router(
        title: 'MolokoAyran',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E7D32),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E7D32),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
