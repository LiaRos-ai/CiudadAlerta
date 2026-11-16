// Día 10 (HU-12): la identidad del release también se prueba.
// 6 pruebas Dart puro sobre ReleaseConfig (sin red, sin Flutter SDK).
import 'package:flutter_test/flutter_test.dart';
import 'package:ciudadalerta/release/release_config.dart';

void main() {
  group('ReleaseConfig del Día 10', () {
    test('la versión 0.9.0+1 cumple semver y coincide con el tag del día', () {
      final c = ReleaseConfig.actual;
      expect(c.esVersionValida, isTrue);
      expect(c.version, '0.9.0');
      expect(c.buildNumber, 1);
      expect(c.etiquetaVersion, 'v0.9.0+1'); // tag Git: v0.9.0-dia10
    });

    test('validarApplicationId: acepta com.ciudadalerta.app y rechaza inválidos', () {
      expect(ReleaseConfig.validarApplicationId('com.ciudadalerta.app'), isNull);
      expect(
          ReleaseConfig.validarApplicationId('ciudadalerta'), isNotNull,
          reason: 'menos de 3 segmentos');
      expect(
          ReleaseConfig.validarApplicationId('com.Ciudad-Alerta.app'), isNotNull,
          reason: 'mayúsculas y guiones no permitidos');
      expect(
          ReleaseConfig.validarApplicationId('com..app'), isNotNull,
          reason: 'segmento vacío');
    });

    test('permisos mínimos: cámara e internet sí, ubicación todavía no (HU-15)', () {
      final c = ReleaseConfig.actual;
      expect(c.permisosAndroid,
          containsAll(['android.permission.INTERNET', 'android.permission.CAMERA']));
      expect(c.permisosAndroid,
          isNot(contains('android.permission.ACCESS_FINE_LOCATION')));
      expect(ReleaseConfig.permisoNoDeclarado('android.permission.ACCESS_FINE_LOCATION'),
          isNotNull, reason: 'ubicación llega en el Sprint 3');
      expect(ReleaseConfig.permisoNoDeclarado('android.permission.CAMERA'), isNull);
    });

    test('el artefacto esperado es app-release.apk en la ruta estándar de Flutter', () {
      final c = ReleaseConfig.actual;
      expect(c.nombreApk, 'app-release.apk');
      expect(c.rutaApk,
          'build/app/outputs/flutter-apk/app-release.apk');
    });

    test('key.properties.example solo viaja con placeholders (MASVS)', () {
      for (final clave in ReleaseConfig.clavesKeyProperties) {
        expect(clave, isNotEmpty);
      }
      expect(ReleaseConfig.esPlaceholderSeguro('CAMBIAME_EN_LOCAL'), isTrue);
      expect(ReleaseConfig.esPlaceholderSeguro('MiPasswordReal2026'), isFalse,
          reason: 'una contraseña real no debe pasar la verificación');
    });

    test('el applicationId oficial es válido y permanente', () {
      expect(ReleaseConfig.actual.applicationId, 'com.ciudadalerta.app');
      expect(
          ReleaseConfig.validarApplicationId(ReleaseConfig.actual.applicationId),
          isNull);
    });
  });
}
