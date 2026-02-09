import 'package:flutter/material.dart';
import 'routes.dart';
import 'app_theme.dart';

class CraveApp extends StatelessWidget {
  const CraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crave',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme, 
      themeMode: ThemeMode.dark, // Enforce Dark Chef's Table theme
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
