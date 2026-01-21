import 'package:flutter/material.dart';
import 'routes.dart';

class CraveApp extends StatelessWidget {
  const CraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crave',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
