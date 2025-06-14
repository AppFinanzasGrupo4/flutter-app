import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';
import 'package:flutter_finanzasapp/presentation/screens/home_emisor.dart';
import 'package:flutter_finanzasapp/presentation/screens/configuration.dart';
import 'package:flutter_finanzasapp/presentation/screens/register_bono.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel usuario;

  const MainNavigationScreen({super.key, required this.usuario});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  @override
Widget build(BuildContext context) {
  return Scaffold(
  backgroundColor: const Color.fromARGB(255, 62, 143, 209), // Color base que usas en tus pantallas
  body: IndexedStack(
    index: _currentIndex,
    children: _pages,
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: _onTap,
    selectedItemColor: Colors.blue, // color de ítem activo
    unselectedItemColor: const Color.fromARGB(255, 0, 0, 0), // ítems inactivos
    backgroundColor: const Color.fromARGB(255, 255, 255, 255), // fondo de la barra
    type: BottomNavigationBarType.fixed, // evita movimiento al cambiar
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Registrar'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ],
  ),
);

}
  @override
@override
void initState() {
  super.initState();
  _pages = [
    HomeEmisorScreen(usuario: widget.usuario),
    const RegisterBonoScreen(), // <---- Aquí usas la versión independiente
    ConfiguracionScreen(usuario: widget.usuario),
    const Placeholder(),
  ];
}

  void _onTap(int index) {
  setState(() {
    _currentIndex = index;
  });
}




}
