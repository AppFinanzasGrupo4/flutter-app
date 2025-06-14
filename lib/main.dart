import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';
import 'package:flutter_finanzasapp/presentation/screens/login.dart';
import 'package:flutter_finanzasapp/presentation/screens/main_navigation_screen.dart';
import 'package:flutter_finanzasapp/presentation/screens/register_bono.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  routes: {
    '/': (context) => Login(), // ← aquí obtendrás el usuario real
    '/home': (context) {
      final user = ModalRoute.of(context)!.settings.arguments as UserModel;
      return MainNavigationScreen(usuario: user);
    },
  },
);

  }
}

