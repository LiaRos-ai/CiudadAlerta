// CiudadAlerta - Evidencia fotografica: Storage (Clase 9 / Dia 9)
// Sprint 2 (Hito 2): HU-11 - "Como ciudadano quiero adjuntar una foto al
// reporte para dar evidencia". Criterios: camara/galeria; sube a Storage;
// muestra miniatura.
//
// RECURSOS NATIVOS (teoria del dia):
//   - image_picker abre la CAMARA o la GALERIA del telefono: son recursos
//     del SO, no de Flutter. Cada uno exige SU permiso.
//   - permission_handler pide/gestiona los permisos: camera (foto nueva),
//     photos (galeria) y storage en Android viejo. Si el ciudadano niega,
//     la app NO se cae: muestra que puede activarlo en Ajustes.
//   - Supabase Storage guarda el ARCHIVO (bucket 'fotos-reportes') y da un
//     URL publico; la tabla report_photos (Día 7) referencia ese URL.
//
// Las FUNCIONES de ruta/validacion son Dart puro: se prueban sin dispositivo
// en test/photo_test.dart. La subida real la hace SupabasePhotoRepository.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Nombre del bucket de Storage del proyecto (se crea en Supabase con
/// db/rls_dia9.sql: ver la seccion STORAGE al final del script).
const bucketFotos = 'fotos-reportes';

/// Extensiones de imagen que la app acepta (foto de reporte, no PDFs).
const extensionesImagenValidas = <String>{'jpg', 'jpeg', 'png', 'webp'};

/// Peso maximo por foto: 5 MB (una foto de camara suele ser 2-4 MB).
const tamanoMaximoBytes = 5 * 1024 * 1024;

/// Devuelve null si [nombreArchivo] es una imagen valida para subir.
/// La UI lo usa ANTES de intentar la subida (fallar rapido y en claro).
String? validarImagen(String nombreArchivo, {int? tamanoBytes}) {
  final extension = nombreArchivo.contains('.')
      ? nombreArchivo.split('.').last.toLowerCase()
      : '';
  if (!extensionesImagenValidas.contains(extension)) {
    return 'Formato no permitido. Usa JPG, PNG o WebP.';
  }
  if (tamanoBytes != null && tamanoBytes > tamanoMaximoBytes) {
    return 'La foto supera 5 MB. Reduce la calidad e intenta de nuevo.';
  }
  return null;
}

/// Ruta DENTRO del bucket: `{usuarioId}/{codigo}-{nombre-seguro}.ext`.
///
/// Por que esa forma:
///   - Una CARPETA por usuario: la politica de Storage del Dia 9 limita
///     que cada cuenta escriba solo en su propia carpeta (RLS de archivos).
///   - El codigo del reporte agrupa las fotos de un mismo reporte.
///   - El nombre se NORMALIZA (minusculas, sin espacios, sin acentes):
///     "Foto La Paz Ñ.jpg" en un URL se vuelve %20Foto%20La%20Paz%20%C3%91
///     y complica consultas; el nombre seguro evita ese dolor.
String rutaDeFoto({
  required String usuarioId,
  required String codigoReporte,
  required String nombreArchivo,
}) {
  if (usuarioId.trim().isEmpty) {
    throw ArgumentError('usuarioId es obligatorio para acotar la carpeta.');
  }
  if (codigoReporte.trim().isEmpty) {
    throw ArgumentError('codigoReporte es obligatorio.');
  }
  final extension = nombreArchivo.contains('.')
      ? nombreArchivo.split('.').last.toLowerCase()
      : '';
  if (!extensionesImagenValidas.contains(extension)) {
    throw ArgumentError('Extensión de imagen inválida: .$extension');
  }
  final base = nombreArchivo.substring(
      0, nombreArchivo.length - extension.length - 1);
  final seguro = _normalizar(base);
  final finalName = seguro.isEmpty ? 'foto' : seguro;
  return '$usuarioId/$codigoReporte-$finalName.$extension';
}

/// Minusculas, sin acentes, sin espacios (guion bajo), solo [a-z0-9_-].
String _normalizar(String texto) {
  const conAcento = 'áàäéèëíìïóòöúùüñç';
  const sinAcento = 'aaaeeeiiiooouuunc';
  var s = texto.toLowerCase().trim();
  for (var i = 0; i < conAcento.length; i++) {
    s = s.replaceAll(conAcento[i], sinAcento[i]);
  }
  return s
      .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

/// Contrato de subida de fotos (misma filosofia de la capa datos: UNA
/// interfaz, dos implementaciones).
abstract class PhotoRepository {
  /// Sube la imagen y devuelve el URL publico para la miniatura (HU-11).
  Future<String> subirFoto({
    required String usuarioId,
    required String codigoReporte,
    required String rutaLocal,
  });
}

/// Implementacion DEMO: no hay red ni Storage; devuelve un URL simulado
/// con la ruta final embebida para que la UI y las pruebas la verifiquen.
class MockPhotoRepository implements PhotoRepository {
  MockPhotoRepository({this.latencia = const Duration(milliseconds: 500)});

  final Duration latencia;

  @override
  Future<String> subirFoto({
    required String usuarioId,
    required String codigoReporte,
    required String rutaLocal,
  }) async {
    await Future.delayed(latencia);
    final ruta = rutaDeFoto(
      usuarioId: usuarioId,
      codigoReporte: codigoReporte,
      nombreArchivo: rutaLocal.split('/').last,
    );
    return 'https://demo.supabase.co/storage/v1/object/public/$bucketFotos/$ruta';
  }
}

/// Implementacion REAL: Storage de Supabase.
///
/// upsert:true permite reintentar la misma foto sin error 409 (duplicado):
/// la ruta determinista usuario/reporte-nombre hace idempotente la subida.
class SupabasePhotoRepository implements PhotoRepository {
  SupabasePhotoRepository(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<String> subirFoto({
    required String usuarioId,
    required String codigoReporte,
    required String rutaLocal,
  }) async {
    final ruta = rutaDeFoto(
      usuarioId: usuarioId,
      codigoReporte: codigoReporte,
      nombreArchivo: rutaLocal.split('/').last,
    );
    try {
      await _cliente.storage.from(bucketFotos).upload(
            ruta,
            File(rutaLocal),
            fileOptions: const FileOptions(upsert: true),
          );
      return _cliente.storage.from(bucketFotos).getPublicUrl(ruta);
    } on StorageException catch (e) {
      throw StateError('No se pudo subir la foto a Storage: ${e.message}');
    }
  }
}

/// Provider de la capa de fotos (misma decision binaria del Dia 8).
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  if (cliente != null) {
    return SupabasePhotoRepository(cliente);
  }
  return MockPhotoRepository();
});
