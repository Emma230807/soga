import 'package:supabase_flutter/supabase_flutter.dart';

class MateriasSupabase {
  static final supabase = Supabase.instance.client;

  static Future<void> registrarMateria(String nombre) async {
    await supabase.from('materia').insert({'nombre': nombre});
  }

  static Future<List<Map<String, dynamic>>> obtenerMaterias() async {
    final resultado = await supabase
        .from('materia')
        .select('idMateria, nombre')
        .order('nombre');

    return List<Map<String, dynamic>>.from(resultado);
  }
}
