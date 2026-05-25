import 'package:flutter/material.dart'; // SDK base de Flutter — proporciona widgets, temas y el motor de renderizado
import 'core/theme/app_theme.dart'; // Tema oscuro centralizado de la app
import 'features/welcome/presentation/screens/welcome_ini_screen.dart'; // Primera pantalla visible: dashboard de inicio

/// Punto de entrada de la aplicación.
/// Dart llama a main() al arrancar; es obligatorio que exista exactamente una.
void main() {
  runApp(const ReTrainexApp()); // Monta el árbol de widgets en la pantalla física
}

/// Widget raíz: envuelve toda la app con MaterialApp.
/// Es StatelessWidget porque no necesita ningún estado propio;
/// solo configura tema, rutas y la pantalla inicial.
class ReTrainexApp extends StatelessWidget {
  const ReTrainexApp({super.key}); // super.key reenvía la clave al padre — buena práctica

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Elimina la cinta roja "DEBUG" en la esquina superior derecha
      theme: AppTheme.darkTheme, // Aplica el tema oscuro definido en app_theme.dart a toda la app
      home: const WelcomeIniScreen(userName: 'MARÍA'), // Primera pantalla — hardcodeado hasta que llegue auth real
    );
  }
}
