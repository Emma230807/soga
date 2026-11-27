import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio compatible con el formulario de administradores de SOGA.
/// Usa la Edge Function actual, sin cambiar la sesión autenticada.
class AdministradoresSupabase {
  static SupabaseClient get supabase => Supabase.instance.client;

  static Future<void> registrarAdministrador({
    required String nombre,
    required String numeroEmpleado,
    String? usuario,
    required String correo,
    required String contrasena,
  }) async {
    if (supabase.auth.currentSession == null) {
      throw StateError('No hay una sesión activa');
    }

    final alias = (usuario ?? correo.split('@').first).trim();
    final respuesta = await supabase.functions.invoke(
      'soga-admin-administradores',
      body: {
        'accion': 'crear',
        'nombre': nombre.trim(),
        'numeroEmpleado': numeroEmpleado.trim(),
        'usuario': alias,
        'correo': correo.trim().toLowerCase(),
        'contrasena': contrasena,
      },
    );

    if (respuesta.status < 200 || respuesta.status >= 300) {
      final datos = respuesta.data;
      final mensaje = datos is Map
          ? (datos['error'] ?? datos['mensaje'] ?? 'Error al registrar')
          : 'Error al registrar administrador';
      throw StateError(mensaje.toString());
    }
  }
}
