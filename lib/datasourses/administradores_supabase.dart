import 'package:supabase_flutter/supabase_flutter.dart';

class AdministradoresSupabase {
  static final supabase = Supabase.instance.client;

  static Future<void> registrarAdministrador({
    required String nombre,
    required String numeroEmpleado,
    required String correo,
    required String contrasena,
  }) async {
    final sesion = supabase.auth.currentSession;

    if (sesion == null) {
      throw Exception('No hay una sesión activa');
    }

    await supabase.functions.invoke(
      'registrar-administrador',
      headers: {
        'Authorization': 'Bearer ${sesion.accessToken}',
      },
      body: {
        'nombreCompleto': nombre,
        'numeroEmpleado': numeroEmpleado,
        'correo': correo,
        'contrasena': contrasena,
      },
    );
  }
}