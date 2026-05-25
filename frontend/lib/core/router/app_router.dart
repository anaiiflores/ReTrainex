import 'package:go_router/go_router.dart'; // Paquete de enrutado declarativo para Flutter
import '../../features/auth/presentation/screens/login_screen.dart';    // Pantalla de inicio de sesión
import '../../features/auth/presentation/screens/register_screen.dart'; // Pantalla de registro

/// Configuración centralizada de rutas con go_router.
/// Por ahora solo gestiona el flujo de autenticación (/login, /register).
/// El resto de la app navega con Navigator.push directamente (flujo de sesión).
class AppRouter {
  /// GoRouter estático — existe una única instancia para toda la app.
  /// 'static final' significa que se crea la primera vez que se accede y no cambia.
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // La app arranca siempre en la pantalla de login

    routes: [
      GoRoute(
        path: '/login', // URL lógica de la ruta (no URL real en móvil)
        builder: (context, state) => const LoginScreen(), // Widget que se muestra al navegar a /login
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(), // Widget que se muestra al navegar a /register
      ),
    ],
  );
}
