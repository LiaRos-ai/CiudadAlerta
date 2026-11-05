// CiudadAlerta - Proyecto Guia · Aplicaciones Moviles I (SIS-0180)
// Clase 2 (Dia 2): primera app creada con `flutter create`.
//
// Es la app contador estandar de Flutter. Su unica mision es verificar que el
// entorno completo funciona: SDK + emulador/dispositivo + hot reload.
//
// Practica de hot reload (Laboratorio de la Clase 2):
//   1. Ejecuta la app (F5 en VS Code o `flutter run`).
//   2. Cambia el texto "Presionaste el boton tantas veces:" por otro texto.
//   3. Guarda (Ctrl+S) y mira como la pantalla se actualiza sin recompilar.

import 'package:flutter/material.dart';

void main() {
  runApp(const CiudadAlertaApp());
}

class CiudadAlertaApp extends StatelessWidget {
  const CiudadAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CiudadAlerta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ContadorPage(),
    );
  }
}

class ContadorPage extends StatefulWidget {
  const ContadorPage({super.key});

  @override
  State<ContadorPage> createState() => _ContadorPageState();
}

class _ContadorPageState extends State<ContadorPage> {
  int _veces = 0;

  void _incrementar() {
    setState(() {
      _veces++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CiudadAlerta · Dia 2'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Presionaste el boton tantas veces:'),
            Text(
              '$_veces',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementar,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}
