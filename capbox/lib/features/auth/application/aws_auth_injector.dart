import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../presentation/view_models/aws_login_cubit.dart';
import '../presentation/view_models/aws_register_cubit.dart';
import '../../../core/services/aws_auth_service.dart';
import '../../../core/services/aws_api_service.dart';

/// Providers para la funcionalidad de autenticación con AWS Cognito
List<SingleChildWidget> get awsAuthProviders => [
  // LoginCubit con AWS Cognito
  ChangeNotifierProvider<AWSLoginCubit>(
    create:
        (context) => AWSLoginCubit(
          context.read<AWSAuthService>(),
          context.read<AWSApiService>(),
        ),
  ),

  // RegisterCubit con AWS Cognito
  ChangeNotifierProvider<AWSRegisterCubit>(
    create:
        (context) => AWSRegisterCubit(
          context.read<AWSAuthService>(),
          context.read<AWSApiService>(),
        ),
  ),
];
