void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: ".env");

  // Verificar que las credenciales se cargaron correctamente
  print('🔧 MAIN: Verificando credenciales OAuth2...');
  print('🔑 MAIN: OAUTH_CLIENT_ID: capbox-mobile-app');
  print('🔐 MAIN: OAUTH_CLIENT_SECRET: capbox-secret-key-2024');

  runApp(const CapBoxApp());
}
