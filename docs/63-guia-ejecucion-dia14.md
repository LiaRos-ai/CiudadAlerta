# 63 · Guía de ejecución — Voz y notificaciones (Día 14)

Esta guía explica cómo ejecutar el módulo del Día 14 de CiudadAlerta:

- HU-16: dictado por voz en la descripción del reporte.
- HU-17: permiso de notificaciones, token FCM y aviso local.
- HU-19: texto a voz en el detalle del reporte.

La guía corresponde a Android. El dictado y el motor de voz pueden requerir
un dispositivo físico; muchos emuladores no incluyen SpeechRecognizer ni
voces en español.

## 1. Requisitos

Instalar:

- Windows 10 o superior.
- Android Studio con Android SDK.
- Dispositivo Android físico o emulador.
- JDK 17 para Gradle.
- Flutter compatible con Dart `^3.5.0`.
- El SDK fijado por el curso mediante FVM.

Verificar Android:

```powershell
adb devices
```

Debe aparecer un emulador o teléfono con estado `device`. No continuar si
aparece `offline`, `unauthorized` o ningún dispositivo.

Verificar Flutter:

```powershell
fvm flutter --version
fvm flutter doctor
```

Si FVM no está instalado, se puede usar temporalmente Flutter 3.24.5 con
Dart 3.5.x:

```powershell
C:\src\flutter\bin\flutter.bat --version
```

No usar `flutter upgrade`: el curso mantiene una versión congelada.

## 2. Preparar el proyecto

Abrir una terminal en la raíz del repositorio:

```powershell
cd C:\Users\...\WORKSPACE\R\UPDS\MOVIL\CiudadAlerta
cd app
fvm flutter clean
fvm flutter pub get
```

Con Flutter instalado directamente:

```powershell
C:\src\flutter\bin\flutter.bat clean
C:\src\flutter\bin\flutter.bat pub get
```

`pub get` debe resolver el módulo de voz. Para el entorno actual, la
dependencia compatible es `speech_to_text: ^7.4.0`.

Verificar el dispositivo seleccionado:

```powershell
fvm flutter devices
```

## 3. Ejecutar sin credenciales externas

Este es el modo recomendado para una primera ejecución. Crea reportes y
sesiones en memoria, sin necesidad de Supabase:

```powershell
fvm flutter run
```

O contra el dispositivo o emulador identificado:

```powershell
fvm flutter run -d emulator-5554
```

En la primera ejecución Android construye el APK debug. Al terminar,
CiudadAlerta aparece en el emulador o teléfono.

1. En la pantalla inicial, tocar **Explorar en modo demo**.
2. Abrir la pestaña **Nuevo**.
3. Verificar que el formulario carga título, categoría, descripción,
   ubicación y micrófono.

Resultado esperado:

- La app abre sin claves Supabase.
- La navegación conserva las cuatro pestañas.
- Los reportes demo están disponibles.
- Las funciones de voz y notificaciones no bloquean el formulario.

## 4. HU-16: dictado de la descripción

El permiso de micrófono se pide al tocar el micrófono del campo, no al
abrir la app.

1. Abrir **Nuevo**.
2. Completar los campos obligatorios que no dependen del micrófono.
3. Tocar el icono de micrófono junto a **Descripción**.
4. Conceder `Grabar audio` si Android lo solicita.
5. Hablar una frase de al menos 10 caracteres, por ejemplo:

```text
Bache grande frente al mercado de Miraflores
```

6. Observar el texto mientras aparece en el campo.
7. Pulsar nuevamente el micrófono para detener el dictado.
8. Revisar y editar el texto.
9. Enviar el reporte.

Resultado esperado:

- Android solicita `RECORD_AUDIO` en contexto.
- El campo se actualiza con resultados parciales.
- Los espacios repetidos se eliminan y la primera letra se capitaliza.
- El reporte puede enviarse si conserva al menos 10 caracteres.
- El micrófono puede detenerse sin enviar el reporte.

Comportamientos aceptables sin hardware compatible:

- SnackBar: `Este dispositivo no ofrece reconocimiento de voz`.
- El teclado sigue disponible.
- No se produce un bloqueo ni cierre inesperado.

Para el emulador, activar o probar con Google Voice fuera del entorno de
evaluación no garantiza SpeechRecognizer. Para la evidencia oficial se
recomienda un teléfono físico.

## 5. HU-19: escuchar el detalle

1. Entrar a **Inicio**.
2. Seleccionar un reporte, por ejemplo `RPT-001`.
3. Desplazarse hasta **Escuchar el reporte**.
4. Tocar el botón.

Resultado esperado:

- El sistema encuentra una voz española disponible.
- El motor lee código, título, estado, zona y descripción.
- El botón cambia a **Detener lectura** mientras reproduce.
- Al salir del detalle, la lectura se detiene.

Si el dispositivo no tiene español instalado:

- Puede aparecer:
  `El motor de voz del dispositivo no tiene español instalado`.
- Instalar un motor de voz español en Ajustes de Android.
- Revisar: **Gestión de idiomas > Síntesis de voz**.

## 6. HU-17: aviso local y permiso de notificaciones

El aviso local funciona sin Firebase.

1. Abrir el detalle de un reporte.
2. Tocar **Activar avisos de estado**.
3. En Android 13 o superior, aceptar `Permitir notificaciones`.
4. Esperar el SnackBar de confirmación.

Resultado esperado sin `google-services.json`:

- No ocurre un crash.
- Aparece: `Aviso local de demostración enviado`.
- Android muestra una notificación local con:
  - título: código del reporte;
  - cuerpo: cambio de estado previsto;
  - canal: `avisos-estado`.
- El aviso corresponde al siguiente estado del ciclo.

Resultado esperado si el permiso se deniega:

- No aparece la notificación.
- Aparece un SnackBar que indica abrir:
  `Ajustes > Aplicaciones > CiudadAlerta`.
- La pantalla del detalle sigue operativa.

## 7. Ejecución contra Supabase

El modo real requiere el SQL del proyecto y las credenciales fuera del
repositorio.

Ejecutar en Supabase, en orden:

1. `db/schema.sql`
2. `db/seed.sql`
3. `db/rls_dia9.sql`
4. `db/ubicaciones_dia12.sql`
5. `db/push_tokens_dia14.sql`

Ejecutar el app con:

```powershell
fvm flutter run `
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=TU-CLAVE-ANON
```

Nunca escribir estas claves en Dart o subirlas al repositorio.

Para validar el módulo SQL:

```sql
select count(*) from push_tokens;

update reports
set estado = 'En proceso'
where codigo = 'RPT-001';

select codigo, estado_anterior, estado_nuevo, enviado
from avisos_pendientes
order by creado_en desc
limit 3;
```

Resultado esperado:

- El UPDATE crea una fila en `avisos_pendientes`.
- `estado_anterior` es el estado previo.
- `estado_nuevo` es `En proceso`.
- `enviado` permanece `false` si no existe la Edge Function.

## 8. Configuración opcional de FCM

Sin `google-services.json`, el push real no existe y el aviso local demuestra
el transporte alternativo.

Para habilitar push real:

1. Crear o usar un proyecto Firebase.
2. Registrar la aplicación Android como `com.ciudadalerta.app`.
3. Descargar `google-services.json`.
4. Colocarlo en `app/android/app/google-services.json`.
5. Ejecutar nuevamente:

```powershell
fvm flutter clean
fvm flutter run
```

Este archivo contiene información de configuración y debe permanecer
excluido del repositorio. No colocar el service role ni un token servidor
dentro de la app.

Al activar avisos con una sesión real, el token debe insertarse o actualizarse
en `push_tokens` con el `usuario_id` autenticado.

## 9. Verificación antes de la demo

Ejecutar las pruebas focalizadas:

```powershell
fvm flutter test test/voz_test.dart
fvm flutter test test/crud_demo_test.dart
```

Ejecutar el análisis:

```powershell
fvm flutter analyze
```

Ejecutar toda la suite:

```powershell
fvm flutter test
```

Resultado objetivo según el README: 83 pruebas verdes y análisis sin
errores de compilación. En caso de diferencias por dependencias o SDK,
guardar el resultado exacto y corregir primero el error reportado.

## 10. Checklist de evidencia

- [ ] La app abre en modo demo.
- [ ] El micrófono solicita permiso en contexto.
- [ ] La descripción cambia en vivo mientras se dicta.
- [ ] El texto dictado supera la validación de 10 caracteres.
- [ ] El detalle lee código, título, estado, zona y descripción.
- [ ] Salir del detalle detiene la voz.
- [ ] `Activar avisos de estado` solicita el permiso en Android 13+.
- [ ] Sin Firebase aparece el aviso local de demostración.
- [ ] Sin permiso/motor, la app sigue operativa.
- [ ] El SQL crea una fila en `avisos_pendientes`.
- [ ] No se incluyó ninguna clave real en Git.

## 11. Errores frecuentes

### No aparece el dispositivo

Reiniciar el puente ADB:

```powershell
adb kill-server
adb start-server
adb devices
```

Para Android Studio:

1. Abrir Device Manager.
2. Iniciar el emulador.
3. Esperar a que el arranque haya terminado.
4. Ejecutar `adb devices`.

### El emulador no reconoce la voz

SpeechRecognizer no está garantizado en emuladores. Usar un teléfono físico
y comprobar que el servicio de reconocimiento de voz está instalado.

### No se escucha español

Instalar una voz española y seleccionar español en:

```text
Ajustes > Gestión de idiomas > Síntesis de voz
```

### No aparece la notificación

Comprobar:

- Permiso `POST_NOTIFICATIONS` concedido.
- Android 13 o superior.
- Canal `avisos-estado` creado.
- App abierta o ejecutándose para la demostración local.

### El push no registra token

Comprobar:

- `google-services.json` en `app/android/app/`.
- Sesión iniciada con usuario real.
- Tabla `push_tokens` creada.
- Políticas RLS ejecutadas.
- Aplicación autenticada contra el mismo proyecto Supabase.
