import 'package:supabase_flutter/supabase_flutter.dart';

class ProfesoresSupabase {
  static final supabase = Supabase.instance.client;

  static Future<void> registrarProfesor({
    required String numeroEmpleado,
    required String nombre,
    required String usuario,
    required String correo,
    required String contrasena,
  }) async {
    final sesion = supabase.auth.currentSession;

    if (sesion == null) {
      throw Exception('No hay una sesión activa');
    }

    await supabase.functions.invoke(
      'registrar-profesor',
      headers: {'Authorization': 'Bearer ${sesion.accessToken}'},
      body: {
        'numeroEmpleadoProf': numeroEmpleado,
        'nombreCompleto': nombre,
        'usuario': usuario,
        'correo': correo,
        'contrasena': contrasena,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerProfesores() async {
    final resultado = await supabase.rpc('consultar_profesores');

    return List<Map<String, dynamic>>.from(resultado);
  }
}
