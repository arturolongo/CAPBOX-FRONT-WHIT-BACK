import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../data/data_sources/planning_api_client.dart';
import '../data/repositories/planning_repository_impl.dart';
import '../domain/repositories/planning_repository.dart';

final planningProviders = [
  Provider<PlanningApiClient>(
    create: (context) => PlanningApiClient(context.read<Dio>()),
  ),
  Provider<PlanningRepository>(
    create:
        (context) => PlanningRepositoryImpl(context.read<PlanningApiClient>()),
  ),
];
