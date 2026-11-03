# 3 · Product Backlog — CiudadAlerta (27 historias de usuario · 118 puntos)

> Backlog inicial creado en el Sprint 0 (Día 1) por el Product Owner (docente).
> Escala de estimación (Planning Poker): **1, 2, 3, 5, 8**. Prioridad **MoSCoW**:
> Must (obligatoria) / Should (deseable) / Could (prescindible si el sprint se atrasa).
> Estado inicial de todas las historias: **Por hacer** (se refina al cierre del Día 5).

## Épica E1 — Fundamentos UI (Sprint 1 · 6 historias · 21 puntos)

| ID | Historia de usuario | Prioridad | Puntos | Día | Criterios de aceptación |
|---|---|---|---|---|---|
| HU-01 | Como ciudadano quiero ver una pantalla de bienvenida e inicio de sesión para acceder a la app. | Must | 3 | 3 | Pantalla con logo, campos y botón; sin errores de layout en 2 tamaños de pantalla. |
| HU-02 | Como usuario quiero navegar por pestañas (Inicio, Mapa, Nuevo, Perfil) para llegar rápido a cada sección. | Must | 3 | 4 | 4 pestañas funcionales con íconos; estado de pestaña activa visible. |
| HU-03 | Como ciudadano quiero ver la lista de reportes para conocer los problemas de mi zona. | Must | 5 | 4 | ListView.builder con tarjetas (título, categoría, fecha); datos mock. |
| HU-04 | Como ciudadano quiero ver el detalle de un reporte para conocer su descripción y estado. | Must | 3 | 4 | Navegación con parámetro; muestra todos los campos del reporte. |
| HU-05 | Como ciudadano quiero llenar un formulario de nuevo reporte con validación para evitar errores. | Must | 5 | 4 | Validación con Form / TextFormField; mensajes de error claros; no envía si es inválido. |
| HU-06 | Como usuario quiero tema claro/oscuro para usar la app cómodamente. | Could | 2 | 5 | Respeta la configuración del sistema; contraste legible. |

## Épica E2 — Datos y BD (Sprint 2 · 7 historias · 31 puntos)

| ID | Historia de usuario | Prioridad | Puntos | Día | Criterios de aceptación |
|---|---|---|---|---|---|
| HU-07 | Como usuario quiero guardar borradores locales para no perder lo escrito sin conexión. | Should | 3 | 6 | Borrador persiste al cerrar la app (shared_preferences / sqflite). |
| HU-08 | Como usuario quiero registrarme e iniciar sesión para gestionar mis reportes. | Must | 5 | 9 | Supabase Auth; sesión persistente; cierre de sesión. |
| HU-09 | Como ciudadano quiero ver reportes desde la BD con filtro por categoría y orden por fecha. | Must | 5 | 8 | Consulta con filtros; estados loading/error/empty. |
| HU-10 | Como ciudadano quiero crear, editar y eliminar mis reportes. | Must | 5 | 8 | CRUD completo; RLS impide editar reportes ajenos. |
| HU-11 | Como ciudadano quiero adjuntar una foto al reporte para dar evidencia. | Should | 5 | 9 | Cámara/galería; sube a Storage; muestra miniatura. |
| HU-12 | Como docente quiero un APK instalable para probar la app en dispositivos reales. | Must | 3 | 10 | APK release generado con `flutter build apk`; ícono y splash configurados. |
| HU-13 | Como autoridad quiero ver estadísticas por categoría y estado para priorizar atención. | Should | 5 | 8 | Consulta agregada (GROUP BY) y gráfico en pantalla. |

## Épica E3 — APIs (Sprint 3 · 7 historias · 34 puntos)

| ID | Historia de usuario | Prioridad | Puntos | Día | Criterios de aceptación |
|---|---|---|---|---|---|
| HU-14 | Como ciudadano quiero ver los reportes en un mapa para ubicarlos fácilmente. | Must | 5 | 12 | Google Maps con marcadores; toque abre el detalle. |
| HU-15 | Como ciudadano quiero que la app detecte mi ubicación y dirección para reportar rápido. | Must | 5 | 13 | Permiso de ubicación; reverse geocoding; manejo de permiso denegado. |
| HU-16 | Como ciudadano quiero dictar la descripción por voz para reportar sin escribir. | Should | 5 | 14 | Reconocimiento de voz en español; edición del texto resultante. |
| HU-17 | Como ciudadano quiero recibir una notificación cuando cambie el estado de mi reporte. | Should | 5 | 14 | Push al actualizar estado; token guardado por usuario. |
| HU-18 | Como ciudadano quiero sugerencias automáticas de categoría a partir de la foto (Amazon Rekognition). | Should | 8 | 15 | Lambda + API Gateway devuelve etiquetas; clave nunca en la app. |
| HU-19 | Como usuario quiero escuchar el detalle del reporte (texto a voz) para accesibilidad. | Could | 3 | 14 | Botón "escuchar" con flutter_tts. |
| HU-20 | Como ciudadano quiero trazar la ruta hacia un reporte. | Could | 3 | 13 | Directions API; muestra distancia y tiempo. |

## Épica E4 — Calidad y cierre (Sprint 4 · 7 historias · 32 puntos)

| ID | Historia de usuario | Prioridad | Puntos | Día | Criterios de aceptación |
|---|---|---|---|---|---|
| HU-21 | Como usuario quiero crear reportes sin conexión y que se sincronicen luego. | Should | 8 | 16 | Cola local; sincroniza al recuperar red; sin duplicados. |
| HU-22 | Como equipo queremos pruebas unitarias y pruebas beta para asegurar la calidad. | Must | 5 | 17 | 10 o más pruebas unitarias en verde; 5 usuarios beta; SUS aplicado. |
| HU-23 | Como usuario quiero una app fluida y accesible. | Should | 3 | 16 | ListView.builder y widgets const; contraste y áreas táctiles de 48 dp o más. |
| HU-24 | Como equipo queremos proteger datos y claves para cumplir seguridad básica. | Must | 5 | 18 | RLS revisadas; claves restringidas; secretos fuera del repositorio (`--dart-define` / GitHub Secrets); checklist MASVS. |
| HU-25 | Como moderador quiero cambiar el estado de los reportes desde un panel. | Should | 5 | 18 | Rol admin; solo admin cambia estado; dispara notificación. |
| HU-26 | Como evaluador quiero documentación y video demo para entender y usar la app. | Must | 3 | 19 | README, manual de usuario, diagrama de arquitectura y video de 3 min. |
| HU-27 | Como equipo queremos un build de producción firmado y checklist de publicación. | Must | 3 | 19 | AAB/APK firmado; ficha de Play Store preparada (sin publicar). |

## Resumen por sprint

| Sprint | Épica principal | Historias | Puntos planificados | Puntos Must |
|---|---|---|---|---|
| 1 | E1 Fundamentos UI | 6 | 21 | 19 |
| 2 | E2 Datos y BD | 7 | 31 | 18 |
| 3 | E3 APIs | 7 | 34 | 10 |
| 4 | E4 Calidad y cierre | 7 | 32 | 16 |
| **Total** | 4 épicas | **27** | **118** | **63** |

## Definition of Ready (para entrar al sprint)

- [ ] La historia tiene formato "Como [rol] quiero [acción] para [beneficio]".
- [ ] Tiene criterios de aceptación verificables.
- [ ] Está estimada en puntos (escala Fibonacci: 1, 2, 3, 5, 8).
- [ ] No depende de algo que aún no existe, o la dependencia está identificada.
- [ ] Cabe en un sprint y el equipo entiende cómo probarla.

## Definition of Done (para cerrar una historia)

- [ ] El código está en el repositorio con Pull Request revisado por al menos un compañero.
- [ ] La app compila y se ejecuta sin errores en emulador y en un dispositivo real.
- [ ] Cumple todos los criterios de aceptación y fue probada (alfa/beta o unitaria según el sprint).
- [ ] Sin claves ni secretos en el repositorio.
- [ ] Cuenta con evidencia (captura o video corto) y tarjeta movida a "Hecho" en el tablero.
- [ ] Documentación mínima actualizada (README o comentario de decisión).
