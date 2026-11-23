# 62 · Bitácora del Día 14 — CiudadAlerta (voz y notificaciones)

**Daily Scrum (Sprint 3 · Día 14)**

- Ayer: tag `v1.2.0-dia13` empujado; mapa vivo con punto azul y cámara
  al ciudadano; dirección legible con caché y botón "Cómo llegar".
- Hoy: HU-16 (dictar la descripción por voz), HU-17 (aviso cuando
  cambia el estado) y HU-19 (escuchar el detalle).
- Impedimentos: el contrato heredado de buscarPorId/crearReporte (resuelto
  con el fix del commit 3), el micrófono del emulador y el español del
  motor TTS (ver incidencias).

**Quiz de activación (informative)**: tokens de notificación y permisos
de micrófono — el grupo llegó bien de RECORD_AUDIO (patrón del Día 9)
y repasó por qué el token va ligado a auth.uid() (RLS del Día 9).

**La demo de voz y notificaciones (evidencia oficial)**

1. HU-16: tap en el micrófono del campo -> diálogo del sistema ->
   dictado en vivo de "Bache grande frente al mercado de Miraflores" ->
   el texto queda limpio y capitalizado en el campo.
2. HU-19: botón "Escuchar el reporte" -> el motor lee codigo, título,
   estado, zona y descripción; al salir del detalle la voz se detiene.
3. HU-17: botón "Activar avisos de estado" -> permiso POST_NOTIFICATIONS
   -> aviso local "tu reporte RPT-001 pasó de Recibido a En proceso"
   (el mismo payload que la Edge Function enviará como push).
4. Trigger: `update reports set estado='En proceso' where codigo='RPT-001'`
   -> `select * from avisos_pendientes` muestra la fila en cola.

**Incidencias del día**

| Incidencia | Síntoma | Causa | Arreglo |
|---|---|---|---|
| Contrato heredado del Día 13 | la suite no compila contra el mock | la firma de crearReporte del mock no aceptaba latitud/longitud que su cuerpo ya usaba; buscarPorId quedó a medias entre sync (Día 6) y async (Día 8) | commit `fix:` 3: firma completa + contrato Future en interfaz y mock (los select del Día 13 ya pedían las columnas; el problema era el LADO Dart) |
| Micrófono en el emulador | "Este dispositivo no ofrece reconocimiento de voz" | el emulador sin SpeechRecognizer configurado | demo en dispositivo físico (misma regla del GPS); el deterioro elegante mostró el mensaje honesto |
| TTS sin español | la voz lee en inglés o calla | el motor del dispositivo sin voz es-ES instalada | Ajustes > Síntesis de voz > instalar español; el servicio ya responde con el mensaje y la lista de locales |
| POST_NOTIFICATIONS denegado | el aviso local no aparece | Android 13+ silencia sin permiso runtime | se pide en contexto al activar avisos; denegado -> SnackBar con la ruta de Ajustes (sin crash) |

**Estado al cierre**: 17 commits (163 -> 180), tag `v1.3.0-dia14`,
versión 1.3.0+5, suite en 83 pruebas verdes (14 archivos), push_tokens
y avisos_pendientes en la BD, docs/59-62 publicados. Mañana: AWS y
cierre del Sprint 3 (HU-18 + Informe 3 + Review/Retro 3).
