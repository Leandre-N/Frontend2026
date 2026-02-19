import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'pages/screens/login.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SalleEvent',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
