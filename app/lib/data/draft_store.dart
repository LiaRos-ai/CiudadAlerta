// CiudadAlerta - Borradores de reporte (Clase 6 / Dia 6)
// HU-07: "Como usuario quiero guardar borradores locales para no perder
// lo escrito sin conexión".
//
// Criterio de aceptacion: el borrador PERSISTE al cerrar la app
// (shared_preferences) y se restaura en la siguiente sesion.
//
// Por que shared_preferences y no sqflite:
//   - El borrador son 3 campos de texto sueltos (clave-valor): no hay
//     consultas, ni filtros, ni relaciones. shared_preferences basta y es
//     la opcion mas barata (ver docs/24-arquitectura-capas.md).
//   - sqflite entra cuando la entidad se consulta con WHERE/ORDER BY
//     (cache de reportes en el Dia 8) y flutter_secure_storage cuando el
//     dato es sensible (el token JWT de Supabase Auth en el Dia 9).
//
// Punto de extension del Dia 8: cuando el formulario cree reportes reales,
// el borrador agrega la fecha de guardado para expirar drafts viejos.

import 'package:shared_preferences/shared_preferences.dart';

/// Modelo del borrador: los 3 campos del formulario HU-05.
class BorradorReporte {
  const BorradorReporte({
    this.titulo = '',
    this.categoria,
    this.descripcion = '',
  });

  final String titulo;
  final String? categoria;
  final String descripcion;

  /// Un borrador vacio NO debe restaurarse sobre el formulario (si no,
  /// cada apertura pisaria el texto nuevo que el usuario ya escribio).
  bool get vacio =>
      titulo.trim().isEmpty &&
      descripcion.trim().isEmpty &&
      (categoria == null || categoria!.trim().isEmpty);
}

/// Almacen de borradores sobre shared_preferences (clave-valor local).
/// `SharedPreferences.setMockInitialValues({})` en los tests permite
/// probar esta clase SIN dispositivo ni canal de plataforma.
class DraftStore {
  static const _kTitulo = 'borrador_titulo';
  static const _kCategoria = 'borrador_categoria';
  static const _kDescripcion = 'borrador_descripcion';

  /// shared_preferences es async por diseño (canal de plataforma):
  /// cada metodo resuelve la instancia y opera. Es barato y seguro.
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Guarda el borrador completo. Se llama en cada cambio del formulario:
  /// para 3 campos de texto el costo es despreciable (en produccion se
  /// aplicaria debounce de ~300 ms; ver cheatsheet de la Guia Practica).
  Future<void> guardar(BorradorReporte borrador) async {
    final prefs = await _prefs;
    await prefs.setString(_kTitulo, borrador.titulo);
    await prefs.setString(_kDescripcion, borrador.descripcion);
    final cat = borrador.categoria;
    if (cat == null || cat.isEmpty) {
      await prefs.remove(_kCategoria);
    } else {
      await prefs.setString(_kCategoria, cat);
    }
  }

  /// Lee el borrador guardado. Si la clave no existe devuelve el borrador
  /// vacio (el llamador decide con .vacio si restaura o no).
  Future<BorradorReporte> cargar() async {
    final prefs = await _prefs;
    return BorradorReporte(
      titulo: prefs.getString(_kTitulo) ?? '',
      categoria: prefs.getString(_kCategoria),
      descripcion: prefs.getString(_kDescripcion) ?? '',
    );
  }

  /// Borra el borrador: se invoca cuando el reporte se envia con exito.
  Future<void> limpiar() async {
    final prefs = await _prefs;
    await prefs.remove(_kTitulo);
    await prefs.remove(_kCategoria);
    await prefs.remove(_kDescripcion);
  }
}
