import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionesPush {
  static final messaging = FirebaseMessaging.instance;
  static final supabase = Supabase.instance.client;

  static StreamSubscription<String>? suscripcionToken;
  static String? ultimoToken;

  static Future<void> actualizacionPendiente = Future<void>.value();

  static final notificacionesLocales =
      FlutterLocalNotificationsPlugin();

  static const canal = AndroidNotificationChannel(
    'soga_notificaciones',
    'Notificaciones SOGA',
    description: 'Avisos de tareas, asesorías y profesores',
    importance: Importance.high,
  );

  static StreamSubscription<RemoteMessage>? suscripcionMensajes;

  static Future<void> inicializar() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await configurarNotificacionesLocales();

      await suscripcionMensajes?.cancel();

      suscripcionMensajes = FirebaseMessaging.onMessage.listen(
        (mensaje) async {
          if (supabase.auth.currentUser == null) return;

          try {
            debugPrint('NOTIFICACIÓN RECIBIDA');

            await mostrarNotificacion(mensaje);
          } catch (e) {
            debugPrint(
              'Error al mostrar notificación: ${e.runtimeType}',
            );
          }
        },
      );

      final permisos = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('Permisos: ${permisos.authorizationStatus}');

      if (permisos.authorizationStatus ==
          AuthorizationStatus.authorized) {
        await registrarDispositivo();
      } else {
        debugPrint('Permiso de notificaciones denegado');
      }
    } catch (e) {
      debugPrint('Error en notificaciones: ${e.runtimeType}');
    }
  }

  static Future<void> registrarDispositivo() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final usuario = supabase.auth.currentUser;

      debugPrint('Iniciando registro del dispositivo');
      debugPrint('Usuario autenticado: ${usuario != null}');

      if (usuario == null) return;

      final permisos = await messaging.requestPermission();

      debugPrint('Permisos: ${permisos.authorizationStatus}');

      if (permisos.authorizationStatus !=
          AuthorizationStatus.authorized) {
        return;
      }

      final token = await messaging.getToken();

      debugPrint('Token obtenido: ${token != null}');

      if (token == null) return;

      if (supabase.auth.currentUser?.id != usuario.id) return;

      await supabase.from('dispositivos').upsert({
        'token_fcm': token,
        'auth_uid': usuario.id,
        'plataforma': 'android',
        'actualizado_en': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'token_fcm');

      debugPrint('Dispositivo registrado correctamente');

      await escucharRenovacion(usuario.id, token);

    } on PostgrestException catch (e) {
      debugPrint('ERROR AL REGISTRAR DISPOSITIVO');
      debugPrint('Código SQL: ${e.code}');
      debugPrint('Mensaje: ${e.message}');
    } catch (e) {
      debugPrint('Error al registrar dispositivo: ${e.runtimeType}');
    }
  }

  static Future<void> escucharRenovacion(
    String authUid,
    String tokenActual,
  ) async {
    await suscripcionToken?.cancel();
    await actualizacionPendiente;

    ultimoToken = tokenActual;

    suscripcionToken = messaging.onTokenRefresh.listen((nuevoToken) {
      actualizacionPendiente = actualizacionPendiente.then((_) async {
        try {
          if (supabase.auth.currentUser?.id != authUid) return;

          final tokenAnterior = ultimoToken;

          await supabase.from('dispositivos').upsert({
            'token_fcm': nuevoToken,
            'auth_uid': authUid,
            'plataforma': 'android',
            'actualizado_en':
                DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'token_fcm');

          ultimoToken = nuevoToken;

          if (tokenAnterior != null && tokenAnterior != nuevoToken) {
            await supabase
                .from('dispositivos')
                .delete()
                .eq('token_fcm', tokenAnterior)
                .eq('auth_uid', authUid);
          }

          debugPrint('Token FCM actualizado correctamente');

        } on PostgrestException catch (e) {
          debugPrint('ERROR AL ACTUALIZAR TOKEN');
          debugPrint('Código SQL: ${e.code}');
          debugPrint('Mensaje: ${e.message}');
        } catch (e) {
          debugPrint('Error al actualizar token: ${e.runtimeType}');
        }
      });
    });
  }

  static Future<void> eliminarDispositivo() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    await suscripcionToken?.cancel();
    suscripcionToken = null;

    await actualizacionPendiente;

    final usuario = supabase.auth.currentUser;

    if (usuario == null) return;

    final token = await messaging.getToken();

    final tokens = <String>{
      if (ultimoToken != null) ultimoToken!,
      if (token != null) token,
    };

    for (final tokenGuardado in tokens) {
      await supabase
          .from('dispositivos')
          .delete()
          .eq('token_fcm', tokenGuardado)
          .eq('auth_uid', usuario.id);
    }

    await messaging.deleteToken();

    ultimoToken = null;

    debugPrint('Dispositivo desvinculado correctamente');
  }

  static Future<void> probarEnvio() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final respuesta = await supabase.functions.invoke(
        'enviar-notificacion',
      );

      debugPrint('Respuesta Firebase: ${respuesta.data}');

    } on FunctionException catch (e) {
      debugPrint('Código: ${e.status}');
      debugPrint('Detalle: ${e.details}');
    } catch (e) {
      debugPrint('Error al enviar notificación: ${e.runtimeType}');
    }
  }

  static Future<void> configurarNotificacionesLocales() async {
    const configuracionAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const configuracion = InitializationSettings(
      android: configuracionAndroid,
    );

    await notificacionesLocales.initialize(
      settings: configuracion,
    );

    await notificacionesLocales
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);
  }

  static Future<void> mostrarNotificacion(
    RemoteMessage mensaje,
  ) async {
    final notificacion = mensaje.notification;

    if (notificacion == null) return;

    await notificacionesLocales.show(
      id: (mensaje.messageId ?? mensaje.hashCode.toString())
              .hashCode &
          0x7fffffff,
      title: notificacion.title,
      body: notificacion.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'soga_notificaciones',
          'Notificaciones SOGA',
          channelDescription:
              'Avisos de tareas, asesorías y profesores',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}