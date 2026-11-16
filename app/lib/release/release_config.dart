/// Día 10 (HU-12): la configuración de release como código.
///
/// Dart puro, probable sin red ni Flutter: los mismos datos que viven en
/// `android/app/build.gradle`, `pubspec.yaml` y `AndroidManifest.xml`,
/// verificados por `app/test/release_config_test.dart` para que la
/// identidad de la app no se rompa por un descuido antes del build.
library;

class ReleaseConfig {
  const ReleaseConfig({
    required this.nombreApp,
    required this.applicationId,
    required this.version,
    required this.buildNumber,
    required this.permisosAndroid,
  });

  final String nombreApp;
  final String applicationId;

  /// versionName del pubspec (`version: 0.9.0+1`).
  final String version;

  /// versionCode de Android: Flutter mapea el build number del pubspec.
  final int buildNumber;

  /// Permisos declarados en AndroidManifest.xml (permiso mínimo, Día 9).
  final List<String> permisosAndroid;

  /// La instancia oficial del Día 10: coincide con pubspec 0.9.0+1.
  static const ReleaseConfig actual = ReleaseConfig(
    nombreApp: 'CiudadAlerta',
    applicationId: 'com.ciudadalerta.app',
    version: '0.9.0',
    buildNumber: 1,
    permisosAndroid: [
      'android.permission.INTERNET',
      'android.permission.CAMERA',
      'android.permission.READ_EXTERNAL_STORAGE',
    ],
  );

  /// Etiqueta estable que coincide con el tag Git del día.
  String get etiquetaVersion => 'v$version+$buildNumber';

  /// Nombre del artefacto que produce `flutter build apk --release`.
  String get nombreApk => 'app-release.apk';

  /// Ruta estándar del APK dentro del proyecto Flutter.
  String get rutaApk =>
      'build/app/outputs/flutter-apk/$nombreApk';

  /// La versión debe ser semver (mayor.menor.parche) para el Play Store.
  bool get esVersionValida =>
      RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version);

  /// El applicationId es permanente: segmentos en minúscula, sin guiones
  /// y al menos dos niveles (com | org | bo.edu... + dominio + app).
  static String? validarApplicationId(String id) {
    final segmentos = id.split('.');
    if (segmentos.length < 3) {
      return 'Debe tener al menos 3 segmentos (com.dominio.app)';
    }
    for (final s in segmentos) {
      if (s.isEmpty) return 'Segmento vacío: "$id"';
      if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(s)) {
        return 'Segmento inválido "$s": minúsculas y sin guiones';
      }
    }
    return null;
  }

  /// El manifest no pide permisos que la app no usa (SP-10 / PLATFORM-1):
  /// cámara sí (HU-11), ubicación NO todavía (es HU-15, Sprint 3).
  static String? permisoNoDeclarado(String permiso) {
    const permitidos = {
      'android.permission.INTERNET',
      'android.permission.CAMERA',
      'android.permission.READ_EXTERNAL_STORAGE',
    };
    if (!permiso.startsWith('android.permission.')) {
      return 'El permiso debe calificar con android.permission.';
    }
    return permitidos.contains(permiso) ? null : 'Permiso no usado por la app: $permiso';
  }

  /// key.properties.example SOLO contiene placeholders (MASVS):
  /// ninguna contraseña real viaja en el repositorio.
  static bool esPlaceholderSeguro(String valor) =>
      valor == 'CAMBIAME_EN_LOCAL' || valor.startsWith('CAMBIAME');

  /// Claves esperadas en key.properties (forma documentada en docs/39).
  static const List<String> clavesKeyProperties = [
    'storePassword',
    'keyPassword',
    'keyAlias',
    'storeFile',
  ];
}
