import 'package:flutter/material.dart';
import 'routes.dart';
import 'app_theme.dart';

class CraveApp extends StatelessWidget {
  const CraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crave',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Force light theme even in dark mode
      themeMode: ThemeMode.light, // Always use light theme
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
