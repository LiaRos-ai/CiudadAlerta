// CiudadAlerta - Shell de navegacion con 4 pestañas (Clase 4 / Dia 4)
// HU-02: barra inferior Inicio / Mapa / Nuevo / Perfil.
//
// Criterios de aceptacion:
//  - 4 pestañas funcionales con iconos.
//  - Estado de pestaña activa visible (NavigationBar lo resalta solo).
//
// goBranch conserva el estado de cada rama (IndexedStack): la lista de
// Inicio no se recarga cuando cambias de pestaña y vuelve.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell, // la pantalla de la pestaña activa
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          // Tocar de nuevo la pestaña activa vuelve a su pantalla inicial:
          initialLocation: index == shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Nuevo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
