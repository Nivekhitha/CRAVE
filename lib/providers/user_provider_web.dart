import 'package:flutter/material.dart';

class UserProviderWeb extends ChangeNotifier {
  // Minimal stub for Web testing
  String? get username => "Web Tester";
  bool get isAuthenticated => true;
  
  void init() {
    debugPrint("✅ UserProviderWeb Initialized");
  }
}
