// CiudadAlerta - Notificaciones locales y push (Día 14 / Sprint 3, HU-17)
//
// Dos motores, un solo servicio:
//   - LOCAL (flutter_local_notifications): el aviso se genera EN el
//     dispositivo. Es el que el laboratorio demuestra hoy y el que
//     sostiene el deterioro elegante cuando Firebase no está
//     configurado: sin google-services.json el push no existe, pero
//     la app NO crashea (misma regla que MAPS_API_KEY en el Día 12).
//   - PUSH (firebase_messaging / FCM): el aviso viaja del servidor al
//     dispositivo por token. La ruta completa (proyecto Firebase,
//     trigger de la BD y Edge Function) vive en docs/60; aquí está la
//     pieza de la app: pedir el token y registrarlo en la tabla
//     push_tokens (RLS: cada usuario guarda SOLO su token).
//
// Reglas del día:
//   1. POST_NOTIFICATIONS (Android 13+) se pide EN CONTEXTO: al tocar
//      "Activar avisos de estado", nunca al abrir la app.
//   2. El token NO es secreto, pero ES un dato personal: vive por
//      usuario (PK usuario_id) y la RLS impide leer los ajenos.
//   3. Un canal, un propósito: "avisos-estado".

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'aviso_estado.dart';

class NotificacionesService {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  /// (1) Permiso + canal. Devuelve true si el sistema permite avisar.
  /// Android 13+: POST_NOTIFICATIONS se concede por app y por uso; en
  /// Android < 13 el permiso runtime no existe y devolvemos true.
  Future<bool> inicializar() async {
    if (_inicializado) return true;
    try {
      final estado = await Permission.notification.request();
      final concedido = estado.isGranted || estado.isLimited;
      if (!concedido) return false;
      const android = AndroidInitializationSettings('@mipmap/launcher_icon');
      const ios = DarwinInitializationSettings();
      await _local.initialize(const InitializationSettings(
        android: android,
        iOS: ios,
      ));
      const canal = AndroidNotificationChannel(
        'avisos-estado', // el mismo id que la Edge Function envía
        'Cambios de estado',
        description: 'Avisos cuando se actualiza tu reporte',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(canal);
      _inicializado = true;
      return true;
    } catch (_) {
      return false; // plataforma sin soporte: la app sigue sin avisos
    }
  }

  /// (3) El aviso EXACTO del ciclo (el mismo payload del push). Sin
  /// permiso NO hay aviso ni crash: deterioro elegante.
  Future<void> mostrarAvisoEstado({
    required String codigo,
    required String titulo,
    required String estadoAnterior,
    required String estadoNuevo,
  }) async {
    if (!_inicializado) return;
    await _local.show(
      codigo.hashCode & 0x7fffffff, // id por reporte: actualiza, no apila
      tituloAviso(codigo),
      cuerpoAvisoEstado(
        titulo: titulo,
        estadoAnterior: estadoAnterior,
        estadoNuevo: estadoNuevo,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'avisos-estado',
          'Cambios de estado',
          channelDescription: 'Avisos cuando se actualiza tu reporte',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: codigo,
    );
  }

  /// (2) Push: inicializa Firebase (si la app se compiló con
  /// google-services.json), pide el token FCM y lo UPSERTA en
  /// push_tokens ligado a auth.uid(). Cualquier paso que falle
  /// devuelve null y el aviso local cubre la demo (docs/60).
  Future<String?> registrarToken() async {
    try {
      await Firebase.initializeApp();
      final cliente = Supabase.instance.client;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return null;
      final uid = cliente.auth.currentUser?.id;
      if (uid == null) return null; // sin sesión no hay fila dueña
      await cliente.from('push_tokens').upsert({
        'usuario_id': uid,
        'token': token,
        'plataforma': 'android', // iOS escribiría "ios" (docs/60)
        'actualizado_en': DateTime.now().toUtc().toIso8601String(),
      });
      return token;
    } catch (_) {
      return null; // Firebase no configurado en este build
    }
  }
}
