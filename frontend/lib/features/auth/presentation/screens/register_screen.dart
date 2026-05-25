import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart'; // Textos localizados

/// Pantalla de registro de nuevo usuario.
/// Por ahora es un placeholder — pendiente de implementar el formulario completo.
/// Usa `StatelessWidget` porque no gestiona estado propio todavía.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocaleManager.strings; // Alias para strings localizados
    return Scaffold(
      appBar: AppBar(title: Text(s.registerTitle)), // "REGISTRO"
      body: Center(
        // Texto provisional que indica que la pantalla está pendiente de desarrollo
        child: Text(s.registerPlaceholder), // "Pantalla de registro (próximamente)"
      ),
    );
  }
}
