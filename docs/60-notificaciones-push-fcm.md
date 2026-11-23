# 60 · Notificaciones: locales, push con FCM y Edge Function — CiudadAlerta (Día 14)

Sprint 3 · Hito 3 · HU-17 · de la notificación LOCAL de hoy al PUSH
real que el Hito 4 consumirá con el panel de moderación.

## 1. Local vs push: la decisión en 4 preguntas

| | Notificación LOCAL | PUSH (FCM) |
|---|---|---|
| ¿Quién dispara? | La propia app (en el dispositivo) | El servidor (trigger/Edge Function) |
| ¿Llega con la app cerrada? | No (si la app muere, muere el aviso) | Sí (FCM la entrega aunque muera) |
| ¿Necesita Firebase? | No | Sí (google-services.json + token) |
| ¿Para qué sirve HOY? | Demo del aviso de estado (HU-17) | Avisar cuando la municipalidad cambia el estado |

La arquitectura del día es UNA sola: el MISMO texto (aviso_estado.dart)
sirve para local y para push; solo cambia el transporte.

## 2. El permiso POST_NOTIFICATIONS (Android 13+)

Android 13 convirtió las notificaciones en permiso runtime por app:
sin él, la notificación se SILENCIA (no crashea). El curso lo pide EN
CONTEXTO: al tocar "Activar avisos de estado", con `Permission.
notification.request()`. En Android < 13 el permiso no existe y la
app avisa sin preguntar (el servicio ya contempla ambos mundos).

## 3. La ruta completa del PUSH (docs/60 = receta)

1. **Proyecto Firebase**: consola -> nuevo proyecto -> app Android con
   el package `com.example.ciudadalerta` (el del build.gradle) ->
   descargar `google-services.json` -> `android/app/`. NUNCA al repo
   (está en .gitignore por contener el identificador del proyecto; la
   clave del servidor va en Secretos de Supabase, jamás en la app).
2. **Token**: `FirebaseMessaging.instance.getToken()` — el identificador
   del dispositivo en FCM. Rota: se guarda con UPSERT y se refresca con
   `onTokenRefresh` (Hito 4).
3. **push_tokens**: tabla del Día 14 (`db/push_tokens_dia14.sql`) con
   RLS por `auth.uid()`: cada usuario guarda SOLO su token (PK usuario_id).
4. **Trigger de la BD**: `trg_estado_cambio` escribe en
   `avisos_pendientes` cuando el estado CAMBIA
   (`old.estado IS DISTINCT FROM new.estado` — la misma regla de
   `estadoCambio` en Dart). El aviso queda en cola aunque la Edge
   Function no esté desplegada.
5. **Edge Function (TypeScript)**: se despliega en Supabase
   (`supabase functions deploy notificar-cambio-estado`), lee la cola
   con el `SERVICE_ROLE_KEY` (SECRETO del servidor), llama a FCM HTTP v1
   con la cuenta de servicio y marca `enviado = true`. El código de
   referencia queda en `supabase/functions/notificar-cambio-estado/index.ts`
   del doc (fuera de la app: el service_role nunca viaja al cliente).

```ts
// supabase/functions/notificar-cambio-estado/index.ts (referencia)
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, // SECRETO del servidor
);

Deno.serve(async () => {
  const { data: avisos } = await supabase
    .from('avisos_pendientes').select('*').eq('enviado', false).limit(20);
  for (const a of avisos ?? []) {
    if (!a.usuario_id) { continue; }
    const { data: t } = await supabase.from('push_tokens')
      .select('token').eq('usuario_id', a.usuario_id).maybeSingle();
    if (!t) { continue; }
    const res = await fetch('https://fcm.googleapis.com/v1/projects/'
      + Deno.env.get('FIREBASE_PROJECT_ID') + '/messages:send', {
      method: 'POST',
      headers: {
        Authorization: 'Bearer ' + Deno.env.get('FIREBASE_ACCESS_TOKEN'),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message: {
        token: t.token,
        notification: {
          title: 'CiudadAlerta: tu reporte ' + a.codigo,
          body: '"' + a.titulo + '" pasó de ' + a.estado_anterior
              + ' a ' + a.estado_nuevo + '.',
        },
        android: { notification: { channel_id: 'avisos-estado' } },
        data: { codigo: String(a.codigo) },
      }}),
    });
    await supabase.from('avisos_pendientes')
      .update({ enviado: res.ok }).eq('id', a.id);
  }
  return new Response(JSON.stringify({ procesados: avisos?.length ?? 0 }));
});
```

## 4. Deterioro elegante (la regla del día)

Sin `google-services.json`, `Firebase.initializeApp()` lanza y el
servicio devuelve null: **la fila no viaja, el push no existe, la app
NO crashea** y el aviso LOCAL demuestra el mismo payload. La única
diferencia entre el demo de hoy y el push real es el TRANSPORTE.

## 5. Costos y cuotas (análisis que pide el Informe 3)

| Servicio | Costo | Cuota gratuita | Nota |
|---|---|---|---|
| FCM (envío de push) | 0 | Ilimitada | Firebase gratis para este uso |
| Motor de voz del sistema (dictado) | 0 | - | on-device, sin red |
| Google Speech-to-Text (API, plan B) | por minuto de audio | 60 min/mes | solo si el motor del sistema no alcanza |
| flutter_tts | 0 | - | motor del sistema |

## 6. Prueba cruzada (cierre del día)

Con Firebase configurado (pasos 1-5): cada equipo activa avisos con SU
cuenta (token en push_tokens), el docente ejecuta el UPDATE de estado
en la BD del equipo vecino y el push cruza entre dispositivos — la
misma notificación que el panel de moderación del Hito 4 disparará.
Sin Firebase: la prueba cruzada valida el trigger (`select * from
avisos_pendientes`) y el aviso local en cada dispositivo.
