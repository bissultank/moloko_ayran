import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'data/datasources/app_database.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/cart_local_datasource.dart';
import 'data/datasources/order_local_datasource.dart';
import 'data/datasources/product_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/check_session_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/order_usecases.dart';
import 'domain/usecases/product_usecases.dart';
import 'domain/usecases/register_usecase.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/order/order_bloc.dart';
import 'presentation/blocs/product/product_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase.instance;
  final productDatasource = ProductLocalDatasource(db);
  await productDatasource.seedIfEmpty();

  runApp(MolokoAyranApp(db: db, productDatasource: productDatasource));
}

class MolokoAyranApp extends StatelessWidget {
  const MolokoAyranApp({
    super.key,
    required this.db,
    required this.productDatasource,
  });

  final AppDatabase db;
  final ProductLocalDatasource productDatasource;

  @override
  Widget build(BuildContext context) {
    final authLocalDatasource = AuthLocalDatasource(db);
    final authRepository = AuthRepositoryImpl(authLocalDatasource);

    final productRepository = ProductRepositoryImpl(productDatasource);

    final orderDatasource = OrderLocalDatasource(db);
    final orderRepository = OrderRepositoryImpl(orderDatasource);

    final cartDatasource = CartLocalDatasource(db);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(authRepository),
            registerUseCase: RegisterUseCase(authRepository),
            checkSessionUseCase: CheckSessionUseCase(authRepository),
            authRepository: authRepository,
          ),
        ),
        BlocProvider(
          create: (_) => ProductBloc(
            getAllUseCase: GetAllProductsUseCase(productRepository),
            searchUseCase: SearchProductsUseCase(productRepository),
            getByCategoryUseCase:
                GetProductsByCategoryUseCase(productRepository),
            createUseCase: CreateProductUseCase(productRepository),
            updateUseCase: UpdateProductUseCase(productRepository),
            deleteUseCase: DeleteProductUseCase(productRepository),
          )..add(const ProductLoadAll()),
        ),
        BlocProvider(
          create: (_) => OrderBloc(
            getUserOrdersUseCase: GetUserOrdersUseCase(orderRepository),
            getByStatusUseCase: GetOrdersByStatusUseCase(orderRepository),
            createUseCase: CreateOrderUseCase(orderRepository),
            updateStatusUseCase: UpdateOrderStatusUseCase(orderRepository),
            deleteUseCase: DeleteOrderUseCase(orderRepository),
          ),
        ),
        BlocProvider(
          create: (_) => CartBloc(cartDatasource)..add(const CartLoad()),
        ),
      ],
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
