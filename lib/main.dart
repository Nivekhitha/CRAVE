import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'providers/user_provider.dart';

void main() async {
  // await Hive.initFlutter();
  // await Hive.openBox('user_data');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const CraveApp(),
    ),
  );
}
