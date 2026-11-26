import 'package:supabase_flutter/supabase_flutter.dart';

class MateriasSupabase {
  static final supabase = Supabase.instance.client;

  static Future<void> registrarMateria(String nombre) async {
    await supabase.from('materia').insert({
      'nombre': nombre,
    });
  }
}