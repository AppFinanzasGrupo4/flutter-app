import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/presentation/screens/config_screen.dart';
import 'package:flutter_finanzasapp/presentation/screens/crear_bono_screen.dart';
import 'dashboard_screen.dart';
import 'ver_bonos_screen.dart';

class HomeEmisorScreen extends StatefulWidget {
  const HomeEmisorScreen({super.key});

  @override
  State<HomeEmisorScreen> createState() => _HomeEmisorScreenState();
}

class _HomeEmisorScreenState extends State<HomeEmisorScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const CrearBonoScreen(),
      const VerBonosScreen(),
      ConfigScreen(onSave: () {}), // Reutilizamos la misma pantalla
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Crear Bono',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Ver Bonos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
