import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart'; // Textos localizados del formulario

/// Pantalla de inicio de sesión.
/// Usa `StatefulWidget` porque gestiona el estado del formulario
/// (visibilidad de la contraseña, validaciones, submit).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Clave global que identifica el formulario y permite llamar a `.validate()`.
  /// `GlobalKey<FormState>` conecta este estado con el widget `Form` en el árbol.
  final _formKey = GlobalKey<FormState>();

  /// Controladores de texto para leer/escribir los valores de los campos.
  /// Se crean aquí y se liberan en `dispose` para evitar memory leaks.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// true → la contraseña se muestra como "•••"; false → se muestra en claro.
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Libera los controladores cuando el widget se destruye.
    // Obligatorio: no hacerlo provoca memory leaks porque los controladores
    // mantienen referencias a listeners internos de Flutter.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose(); // Siempre llamar al dispose del padre al final
  }

  /// Valida el campo de email.
  /// Devuelve un String con el error si falla, o null si es válido.
  /// Flutter llama a este método automáticamente cuando se valida el formulario.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleManager.strings.loginEmailRequired; // "El email es requerido"
    }
    if (!value.contains('@')) {
      return LocaleManager.strings.loginEmailInvalid; // "Email inválido"
    }
    return null; // null → sin errores, el campo es válido
  }

  /// Valida el campo de contraseña.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleManager.strings.loginPasswordRequired; // "La contraseña es requerida"
    }
    if (value.length < 6) {
      return LocaleManager.strings.loginPasswordTooShort; // "Mínimo 6 caracteres"
    }
    return null; // Válido
  }

  /// Intenta hacer login si el formulario es válido.
  /// `_formKey.currentState!.validate()` dispara todos los validators
  /// y devuelve true solo si todos retornan null.
  void _login() {
    if (_formKey.currentState!.validate()) {
      // TODO: Llamar al servicio de autenticación real y navegar a HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleManager.strings.loginSuccess), // "Inicio de sesión exitoso"
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleManager.strings; // Alias para reducir verbosidad
    return Scaffold(
      appBar: AppBar(
        title: Text(s.loginTitle), // "INICIAR SESIÓN"
        centerTitle: true,
      ),
      body: SafeArea(
        // SafeArea evita que el contenido quede bajo la barra de estado o el notch
        child: Center(
          child: SingleChildScrollView(
            // Permite hacer scroll si el teclado virtual sube y reduce el espacio disponible
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400), // Limita el ancho en tablet
              child: Form(
                key: _formKey, // Asocia el formulario con su GlobalKey para validación
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Botones ocupan todo el ancho
                  children: [
                    // Logo de la aplicación / hospital
                    const Image(
                        image: AssetImage(
                            'assets/images/SonEspasesIcon-Zqcd-1K2.png')),
                    const SizedBox(height: 16),
                    Text(
                      s.appName, // "ReTrainex"
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.loginSubtitle, // Subtítulo descriptivo de la app
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // ── Campo de email ──────────────────────────────────────
                    TextFormField(
                      controller: _emailController,           // Lee/escribe el valor del campo
                      keyboardType: TextInputType.emailAddress, // Teclado con '@' visible
                      decoration: InputDecoration(
                        labelText: s.loginEmailHint,          // "Correo electrónico"
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail, // Función de validación declarada arriba
                    ),
                    const SizedBox(height: 16),
                    // ── Campo de contraseña ─────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword, // true → oculta los caracteres
                      decoration: InputDecoration(
                        labelText: s.loginPasswordLabel, // "Contraseña"
                        prefixIcon: const Icon(Icons.lock_outline),
                        // Botón al final del campo para alternar visibilidad
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off  // Ojo tachado → pulse para ver
                                : Icons.visibility,     // Ojo abierto → pulse para ocultar
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword; // Alterna el flag
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 24),
                    // ── Botón de submit ─────────────────────────────────────
                    ElevatedButton(
                      onPressed: _login, // Valida y procesa el formulario
                      child: Text(s.loginButton), // "INICIAR SESIÓN"
                    ),
                    const SizedBox(height: 24),
                    // ── Enlace a registro ───────────────────────────────────
                    TextButton(
                      onPressed: () {}, // TODO: navegar a RegisterScreen
                      child: Text(s.loginNoAccount), // "¿No tienes cuenta? Regístrate"
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
