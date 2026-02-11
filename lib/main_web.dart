import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/user_provider_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add sample recipes for web testing (in-memory)
  await _addSampleRecipesWeb();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProviderWeb()),
      ],
      child: const CraveApp(),
    ),
  );
}

Future<void> _addSampleRecipesWeb() async {
  // This will be handled by the UserProviderWeb
  debugPrint('✅ Web version initialized');
}