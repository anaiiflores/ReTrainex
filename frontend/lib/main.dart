import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/welcome/presentation/screens/welcome_ini_screen.dart';

void main() {
  runApp(const ReTrainexApp());
}

class ReTrainexApp extends StatelessWidget {
  const ReTrainexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeIniScreen(userName: 'MARÍA'),
    );
  }
}
