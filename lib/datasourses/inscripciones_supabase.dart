import 'package:supabase_flutter/supabase_flutter.dart';

class InscripcionesSupabase {
  static final supabase = Supabase.instance.client;

  static Future<void> registrarAsignacion({
    required int idMateria,
    required String numeroEmpleado,
    required String idGrupo,
  }) async {
    await supabase.from('asignacion').insert({
      'idMateria': idMateria,
      'numeroEmpleadoProf': numeroEmpleado,
      'idGrupo': idGrupo,
    });
  }
}
