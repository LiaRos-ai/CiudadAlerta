# 51 · Paso a paso: Google Cloud Console, API key y restricciones (Día 12)

> Guía de la evidencia oficial del Día 12 —"Mapa funcional + claves
> restringidas"— para el Proyecto Guía y para el proyecto paralelo de
> cada equipo. La consola es gratis; la facturación exige una tarjeta o
> cuenta de estudiante y SOLO se activa si el docente lo autoriza:
> con las cuotas Free de Maps SDK el laboratorio no genera costo.

## 1. Crear el proyecto en Google Cloud Console

1. Entra a <https://console.cloud.google.com> con la cuenta del equipo.
2. Selector de proyectos (arriba, junto al logo) → **New Project**.
3. Nombre: `ciudadalerta-curso` (o `nombre-del-proyecto-paralelo`).
   Organización: **No organization** (cuenta académica).
4. **Create**; espera la notificación y selecciona el proyecto nuevo.

> Un proyecto de Google Cloud es el "inquilino" que agrupa APIs, claves,
> facturación y presupuestos. La regla del curso: UN proyecto por app,
> nunca claves de un proyecto personal compartidas entre equipos.

## 2. Habilitar la API que se va a usar

1. Menú ☰ → **APIs & Services → Library**.
2. Busca **Maps SDK for Android** → **Enable**.
3. (Opcional para el proyecto paralelo) habilita también **Maps SDK for
   iOS** solo si el equipo demuestra en iPhone; en el curso la demo es
   Android. Directions/Places se habilitan el Día 13 cuando se usen.

> Una API key sin APIs habilitadas da error 403; una API habilitada sin
> restricciones es una puerta abierta. Se hace SIEMPRE en este orden:
> habilitar → crear clave → restringir.

## 3. Crear la API key

1. **APIs & Services → Credentials → + Create Credentials → API key**.
2. Copia la clave (`AIza...`) UNA vez y guárdala en tu gestor local.
3. La clave NO va al chat del equipo, NO va al repo, NO va en capturas
   (tapa los dígitos del medio en las evidencias).

## 4. Restringir la clave (la mitad de la evidencia)

Panel **Edit API key** (Credentials → clic en la clave):

**a) Application restrictions → Android applications:**

- **Add** → Package name: `com.ciudadalerta.app`
  (el `applicationId` del Día 10 en `android/app/build.gradle`; en el
  proyecto paralelo, el de TU app).
- **SHA-1 certificate fingerprint**: obtén el del certificado DEBUG con:

```
keytool -list -v -keystore ~/.android/debug.keystore \
        -alias androiddebugkey -storepass android -keypass android
```

(En Windows el keystore vive en `%USERPROFILE%\.android\debug.keystore`).
Copia la huella `XX:XX:XX...` (40 pares hexadecimales separados por `:`).
Para el APK release del Día 10 se agrega DESPUÉS el SHA-1 del keystore
release (`key.properties`); mientras el curso muestre debug, con el
debug basta y la clave release se crea aparte.

**b) API restrictions → Restrict key →** marca SOLO **Maps SDK for
Android**. Con esto, aunque la clave se filtre, no sirve para otras
APIs del proyecto (facturación de la tarjeta del docente a salvo).

**Save**: la restricción tarda ~5 minutos en propagarse.

## 5. Cuotas y presupuestos (monitoreo)

- **APIs & Services → Quotas**: cada SKU de Maps Platform incluye una
  cuota gratuita mensual (el número vigente se lee en la página de
  pricing y en el propio panel Quotas; cambia con el tiempo, por eso el
  material no lo memoriza: enseña a consultarlo). El aula no la agota,
  pero el panel se configura para aprender a monitorear el consumo.
- **Billing → Budgets & alerts** (si la facturación está activada):
  presupuesto 1 USD con alerta al 50/90/100 %. Si el proyecto no tiene
  facturación activada, el mapa funciona dentro de la capa gratuita y
  el panel de Billing queda como lectura.

## 6. Verificación final (checklist del docente)

- [ ] Proyecto `ciudadalerta-curso` creado y seleccionado.
- [ ] **Maps SDK for Android** habilitado (Library → Enabled).
- [ ] API key creada y visible en Credentials.
- [ ] Restricción de app: `com.ciudadalerta.app` + SHA-1 debug.
- [ ] Restricción de API: solo Maps SDK for Android.
- [ ] `git log -p` del repo NO contiene `AIza` (verificación MASVS).
- [ ] La clave viaja SOLO por `--dart-define=MAPS_API_KEY=...`.

## 7. Errores típicos y su arreglo

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| Mapa en blanco con logo de Google | Clave ausente o no llegó al manifest | Verifica `--dart-define` y el placeholder `${mapsApiKey}` (docs/52, sección 3) |
| Logcat: `AUTHENTICATION_FAILED` / clave rechazada | SHA-1 mal copiado o paquete distinto | Re-compara la huella con `keytool`; confirma `applicationId` |
| Logcat: `API key not valid` | API no habilitada o restricción mal guardada | Habilita Maps SDK for Android; espera 5 min tras guardar |
| `AUTHORIZATION_DENIED` tras un rato | Restricción de API sin Maps SDK | Agrega Maps SDK for Android a la lista |
| Clave funciona en el emulador pero no en el móvil | SHA-1 es solo de debug y el APK es release | Crea clave aparte con el SHA-1 del keystore release |

## 8. Por qué esto importa para el Hito 3

La meta del sprint exige "claves protegidas y consumo monitoreado". Una
API key de Google dentro del APK es, en rigor, una clave COMPROMETIDA
(los APK se descompilan); Google lo compensa con el esquema de
restricciones (paquete + SHA-1), que ata la clave a TU app firmada con
TU certificado. El Día 15 (Lambda + API Gateway) el mismo criterio se
aplica al lado AWS con IAM de mínimo privilegio.
