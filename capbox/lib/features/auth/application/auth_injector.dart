import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../data/data_sources/auth_api_client.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/use_cases/login_user_usecase.dart';
import '../domain/repositories/auth_repository.dart';
import '../presentation/view_models/login_cubit.dart';
import '../presentation/view_models/register_cubit.dart';

final authProviders = [
  Provider<AuthApiClient>(
    create: (context) => AuthApiClient(context.read<Dio>()),
  ),
  Provider<AuthRepository>(
    create: (context) => AuthRepositoryImpl(context.read<AuthApiClient>()),
  ),
  Provider<AuthRepositoryImpl>(
    create: (context) => AuthRepositoryImpl(context.read<AuthApiClient>()),
  ),
  Provider<LoginUserUseCase>(
    create: (context) => LoginUserUseCase(context.read<AuthRepository>()),
  ),
  // Cubits
  ChangeNotifierProvider<LoginCubit>(
    create: (context) => LoginCubit(context.read<LoginUserUseCase>()),
  ),
  ChangeNotifierProvider<RegisterCubit>(
    create: (context) => RegisterCubit(context.read<AuthRepositoryImpl>()),
  ),
];
