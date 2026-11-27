import 'package:supabase_flutter/supabase_flutter.dart';

class InscripcionesSupabase {
  static final supabase = Supabase.instance.client;

  static Future<void> registrarAsignacion({
    required int idMateria,
    required String numeroEmpleado,
    required String idGrupo,
  }) async {
    await supabase.rpc(
      'soga_admin_registrar_asignacion',
      params: {
        'p_id_materia': idMateria,
        'p_numero_empleado': numeroEmpleado,
        'p_id_grupo': idGrupo,
      },
    );
  }
}
