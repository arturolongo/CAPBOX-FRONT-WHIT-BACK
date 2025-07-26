import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:capbox/core/router/app_router.dart';
import 'package:capbox/core/services/auth_service.dart';
import 'package:capbox/core/services/aws_api_service.dart';
import 'package:capbox/core/services/user_display_service.dart';
import 'package:capbox/features/auth/application/auth_injector.dart';
import 'package:capbox/features/auth/application/aws_auth_injector.dart';
import 'package:capbox/features/coach/application/planning_injector.dart';
import 'package:capbox/features/admin/data/services/gym_service.dart';
import 'package:capbox/features/admin/data/services/admin_gym_key_service.dart';
import 'package:capbox/features/admin/presentation/cubit/gym_management_cubit.dart';
import 'package:capbox/features/admin/presentation/cubit/admin_gym_key_cubit.dart';
import 'package:capbox/features/boxer/data/services/user_stats_service.dart';
import 'package:capbox/features/boxer/presentation/cubit/user_stats_cubit.dart';
import 'package:capbox/features/coach/data/services/gym_key_service.dart';
import 'package:capbox/features/coach/presentation/cubit/gym_key_cubit.dart';
import 'package:capbox/features/auth/presentation/view_models/gym_key_activation_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: ".env");

  runApp(const CapBoxApp());
}

class CapBoxApp extends StatelessWidget {
  const CapBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Instancia de Dio para servicios HTTP
        Provider<Dio>(
          create: (_) => Dio(BaseOptions(baseUrl: 'https://api.capbox.site')),
        ),
        // Servicio de autenticación OAuth2
        Provider<AuthService>(
          create: (context) => AuthService(context.read<Dio>()),
        ),
        // Servicio de API con autenticación OAuth2
        Provider<AWSApiService>(
          create: (context) => AWSApiService(context.read<AuthService>()),
        ),
        // Servicio de datos de display del usuario
        Provider<UserDisplayService>(
          create:
              (context) => UserDisplayService(
                context.read<AuthService>(),
                context.read<AWSApiService>(),
              ),
        ),
        // Servicio de gestión de gimnasio
        Provider<GymService>(
          create: (context) => GymService(context.read<AWSApiService>()),
        ),
        // Servicio de clave del gimnasio para admin
        Provider<AdminGymKeyService>(
          create:
              (context) => AdminGymKeyService(context.read<AWSApiService>()),
        ),
        // Servicio de estadísticas del usuario
        Provider<UserStatsService>(
          create: (context) => UserStatsService(context.read<AWSApiService>()),
        ),
        // Servicio de clave del gimnasio
        Provider<GymKeyService>(
          create: (context) => GymKeyService(context.read<AWSApiService>()),
        ),
        // Cubit de gestión del gimnasio
        ChangeNotifierProvider<GymManagementCubit>(
          create: (context) => GymManagementCubit(context.read<GymService>()),
        ),
        // Cubit de clave del gimnasio para admin
        ChangeNotifierProvider<AdminGymKeyCubit>(
          create:
              (context) => AdminGymKeyCubit(context.read<AdminGymKeyService>()),
        ),
        // Cubit de estadísticas del usuario
        ChangeNotifierProvider<UserStatsCubit>(
          create: (context) => UserStatsCubit(context.read<UserStatsService>()),
        ),
        // Cubit de clave del gimnasio
        ChangeNotifierProvider<GymKeyCubit>(
          create: (context) => GymKeyCubit(context.read<GymKeyService>()),
        ),
        // Cubit de activación con clave del gimnasio
        ChangeNotifierProvider<GymKeyActivationCubit>(
          create:
              (context) => GymKeyActivationCubit(
                context.read<AWSApiService>(),
                context.read<AuthService>(),
              ),
        ),
        // Nuevos providers con AWS Cognito
        ...awsAuthProviders,
        // Mantener providers de planificación
        ...planningProviders,
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'CapBox',
        routerConfig: appRouter,
        theme: ThemeData.dark().copyWith(
          // Customizar tema aquí si es necesario
          primaryColor: Colors.red,
          colorScheme: ColorScheme.dark(
            primary: Colors.red,
            secondary: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
