// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/link_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const LinkHiveApp());
}

class LinkHiveApp extends StatelessWidget {
  const LinkHiveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LinkProvider()),
      ],
      child: MaterialApp.router(
        title: 'LinkHive',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}