import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocaleManager.strings;
    return Scaffold(
      appBar: AppBar(title: Text(s.registerTitle)),
      body: Center(
        child: Text(s.registerPlaceholder),
      ),
    );
  }
}
