# 59 · Voz: dictado y texto a voz — CiudadAlerta (Día 14)

Sprint 3 · Hito 3 · HU-16 y HU-19 · la app aprende a ESCUCHAR y a HABLAR.

## 1. Las dos mitades del día

| | Reconocimiento (voz -> texto) | Síntesis (texto -> voz) |
|---|---|---|
| Paquete | `speech_to_text` | `flutter_tts` |
| Motor | SpeechRecognizer del sistema (Android) / SFSpeechRecognizer (iOS) | TTS del sistema |
| ¿Dónde corre? | EN el dispositivo (offline en la mayoría) | EN el dispositivo (siempre) |
| Costo | 0 con el motor del sistema; la API de Google Speech-to-Text cobra por minuto (60 min/mes gratis) | 0, siempre |
| HU | HU-16 (dictar la descripción) | HU-19 (escuchar el detalle) |
| Permiso | RECORD_AUDIO (runtime, en contexto) | Ninguno |

La regla didáctica es la misma de los Días 9 y 13: **el permiso mejora
el reporte, jamás lo bloquea**. Sin micrófono el ciudadano escribe con
el teclado; sin español instalado en el motor de voz, el detalle sigue
leyéndose con los ojos.

## 2. El permiso del micrófono en contexto

Mismo patrón que la cámara (Día 9) y la ubicación (Día 13):

1. `RECORD_AUDIO` se DECLARA en el manifest (compila sin permiso).
2. El permiso RUNTIME se pide con `Permission.microphone.request()`
   SOLO al tocar el botón de dictar (el `suffixIcon` del campo).
3. Negado una vez: SnackBar con la explicación y el teclado sigue.
4. `initialize()` puede fallar (emulador sin SpeechRecognizer): se
   devuelve `false` y el mensaje es honesto — nunca una excepción.

## 3. Dictado EN VIVO (HU-16)

- `partialResults: true`: el campo se actualiza mientras el ciudadano
  habla (resultados parciales), no al terminar.
- `localeId: 'es_BO'`: el motor resuelve la variante del sistema.
- `limpiarTranscripcion` recorta, colapsa espacios y capitaliza: el
  texto del dictado entra limpio al campo (lógica pura, probada).
- La transcripción REEMPLAZA el contenido del campo: el ciudadano
  revisa antes de enviar; el borrador HU-07 persiste cada cambio.
- `transcripcionSuficiente` aplica la MISMA regla de 10 caracteres del
  validador HU-05: dictar no baja la barra de calidad del reporte.

## 4. Escuchar el reporte (HU-19)

- `_BotonEscuchar` lee `textoParaLeer(...)`: codigo, título, estado,
  zona y descripción como una noticia — no lee etiquetas de UI.
- `localeTts(instalados)` elige es_BO -> es_MX -> es_ES -> es_US -> es;
  si el motor enumeró voces y ninguna es española, mensaje honesto.
- Salir de la pantalla silencia (`dispose` -> `silenciar()`): la voz
  NUNCA sigue hablando en otra pantalla.
- Accesibilidad en dos capas: TalkBack lee la UI (Semantics del Día 4)
  y el botón lee el CONTENIDO cuando el ciudadano lo pide. El ritmo
  0.5 es medio: claro sin arrastrar (el Hito 4 lo hará ajustable).

## 5. Errores frecuentes

1. El diálogo del micrófono no aparece: faltó el permiso runtime (solo
   se declaró el manifest) o el emulador no tiene micrófono virtual
   (la demo se hace en dispositivo físico, como el GPS del Día 13).
2. "Este dispositivo no ofrece reconocimiento de voz": SpeechRecognizer
   ausente en el emulador o sin servicio de voz instalado — probar en
   un teléfono real.
3. La voz del TTS sale en inglés: el motor no tiene español instalado
   (Ajustes > Gestión de idiomas > Síntesis de voz) — el mensaje del
   servicio lo anticipa.
4. El dictado sobreescribe lo escrito: es el comportamiento esperado;
   el campo es editable y el borrador guarda cada versión.

## 6. Checklist de la demo (HU-16 / HU-19)

- [ ] Manifest con RECORD_AUDIO y POST_NOTIFICATIONS.
- [ ] El permiso de micrófono se pide al PRIMER tap de dictar.
- [ ] El texto aparece EN VIVO en el campo mientras se dicta.
- [ ] Un reporte dictado pasa la validación de 10 caracteres.
- [ ] "Escuchar el reporte" lee codigo, título, estado, zona y descripción.
- [ ] Salir del detalle detiene la voz.
- [ ] Sin permiso/motor, la app sigue con el teclado (sin crash).
