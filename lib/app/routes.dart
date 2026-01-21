import 'package:flutter/material.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String home = '/home';
  // Add other routes here

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Onboarding')))); 
      // replace with actual screens later
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Error'))));
    }
  }
}
