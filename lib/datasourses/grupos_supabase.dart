import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soga/models/grupo.dart';

class GruposSupabase {
  static final supabase = Supabase.instance.client;

  static Future<void> registrarGrupo(Grupo grupo) async {
    await supabase.from('grupo').insert({
      'idGrupo': grupo.idGrupo,
      'nombreGrupo': grupo.nombreGrupo,
    });
  }
}