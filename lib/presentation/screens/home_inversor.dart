import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';

class HomeInversorScreen extends StatelessWidget {
  final UserModel usuario;
  const HomeInversorScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Inversor')),
      body: Center(child: Text('Bienvenido, ${usuario.nombre}')),
    );
  }
}