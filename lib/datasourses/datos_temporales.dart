import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soga/models/docente.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/models/vinculacion_docente_alumno.dart';
import 'package:soga/models/asesoria.dart';
import 'package:soga/models/nota.dart';
import 'package:soga/services/notificaciones_push.dart';


class DatosTemporales {
  // La sesión y los datos de la aplicación provienen de Supabase.
  static UsuarioSesion? _sesionSupabase;
  static UsuarioSesion? get sesionActual => _sesionSupabase;

  static Future<UsuarioSesion> iniciarSesionSupabase(
    String correo,
    String contrasena,
  ) async {
    final client = Supabase.instance.client;
    final auth = await client.auth.signInWithPassword(
      email: correo.trim(),
      password: contrasena,
    );
    final cuenta = auth.user;
    if (cuenta == null) {
      throw StateError('No se pudo iniciar sesion en Supabase Auth.');
    }

    try {
      final perfil = await client
          .from('usuario')
          .select('idUsuario, nombreCompleto, correo, tipoUsuario')
          .eq('auth_uid', cuenta.id)
          .single();
      final id = (perfil['idUsuario'] as num).toInt();
      final tipo = perfil['tipoUsuario'] as String;
      final RolUsuario rol;
      String? matricula;
      String? numeroEmpleadoProf;
      String? numeroEmpleadoAdmin;

      switch (tipo) {
        case 'ALUMNO':
          rol = RolUsuario.alumno;
          final alumno = await client
              .from('alumno')
              .select('matricula')
              .eq('idUsuario', id)
              .single();
          matricula = alumno['matricula'] as String;
          break;
        case 'PROFESOR':
          rol = RolUsuario.docente;
          final profesor = await client
              .from('profesor')
              .select('numeroEmpleadoProf')
              .eq('idUsuario', id)
              .single();
          numeroEmpleadoProf = profesor['numeroEmpleadoProf'] as String;
          break;
        case 'ADMINISTRADOR':
          rol = RolUsuario.administrador;

          final administrador = await client
              .from('administrador')
              .select('numeroEmpleado')
              .eq('idUsuario', id)
              .single();

          numeroEmpleadoAdmin = administrador['numeroEmpleado'] as String;

          break;
        default:
          throw Exception('Tipo de usuario no reconocido');
      }

      final sesion = UsuarioSesion(
        id: id,
        nombre: perfil['nombreCompleto'] as String,
        correo: perfil['correo'] as String,
        rol: rol,
        matricula: matricula,
        authUid: cuenta.id,
        numeroEmpleadoProf: numeroEmpleadoProf,
        numeroEmpleadoAdmin: numeroEmpleadoAdmin,
      );
      _sesionSupabase = sesion;

      await NotificacionesPush.registrarDispositivo();

      return sesion;
    } catch (_) {
      _sesionSupabase = null;
      await client.auth.signOut();
      rethrow;
    }
  }

  // Adaptador de sesión necesario para HomeDocente.
  static Docente docenteDesdeSesion(UsuarioSesion sesion) {
    if (sesion.rol != RolUsuario.docente || sesion.numeroEmpleadoProf == null) {
      throw StateError('La sesion no corresponde a un profesor.');
    }
    return Docente(
      id: sesion.id,
      nombre: sesion.nombre,
      correo: sesion.correo,
      contrasena: '', // No se guardan credenciales en el modelo.
    );
  }

 static Future<void> cerrarSesionSupabase() async {
  await NotificacionesPush.eliminarDispositivo();

  await Supabase.instance.client.auth.signOut();

  _sesionSupabase = null;
}

  // Opciones visuales de la interfaz (no son datos de prueba).
  static const List<String> prioridades = ['Alta', 'Media', 'Baja'];

  static const List<Color> coloresNota = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  static Future<List<Map<String, dynamic>>> obtenerTareasSupabase() async {
    final supabase = Supabase.instance.client;

    // 1. Obtener el usuario autenticado
    final usuarioAuth = supabase.auth.currentUser;

    if (usuarioAuth == null) {
      throw Exception('No hay un usuario autenticado');
    }

    // 2. Obtener su perfil
    final perfil = await supabase
        .from('usuario')
        .select('idUsuario, tipoUsuario')
        .eq('auth_uid', usuarioAuth.id)
        .single();

    if (perfil['tipoUsuario'] != 'ALUMNO') {
      throw Exception('La cuenta no corresponde a un alumno');
    }

    // 3. Obtener la matrícula del alumno autenticado
    final alumno = await supabase
        .from('alumno')
        .select('matricula')
        .eq('idUsuario', perfil['idUsuario'])
        .single();

    final matricula = alumno['matricula'] as String;

    // 4. Consultar sus tareas en PostgreSQL
    final resultado = await supabase
        .from('tarea')
        .select()
        .eq('matricula', matricula)
        .order('fecha', ascending: true);

    return List<Map<String, dynamic>>.from(resultado);
  }

  static Future<void> cambiarEstadoTareaSupabase(
    int idTarea,
    bool completada,
  ) async {
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) {
      throw Exception('No hay un usuario autenticado');
    }

    final resultado = await supabase
        .from('tarea')
        .update({'completada': completada})
        .eq('idTarea', idTarea)
        .select('idTarea');

    if (resultado.isEmpty) {
      throw Exception(
        'No se encontró la tarea o no tienes permiso para actualizarla',
      );
    }
  }

  static Future<void> eliminarTareaSupabase(int idTarea) async {
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) {
      throw Exception('No hay un usuario autenticado');
    }

    final resultado = await supabase
        .from('tarea')
        .delete()
        .eq('idTarea', idTarea)
        .select('idTarea');

    if (resultado.isEmpty) {
      throw Exception(
        'No se encontró la tarea o no tienes permiso para eliminarla',
      );
    }
  }

  static Future<void> guardarTareaSupabase({
    required String titulo,
    required String descripcion,
    required String prioridad,
    required DateTime fecha,
    required int idMateria,
    required String color,
  }) async {
    final supabase = Supabase.instance.client;

    final usuarioAuth = supabase.auth.currentUser;

    if (usuarioAuth == null) {
      throw Exception('No hay un usuario autenticado');
    }

    final perfil = await supabase
        .from('usuario')
        .select('idUsuario, tipoUsuario')
        .eq('auth_uid', usuarioAuth.id)
        .single();

    if (perfil['tipoUsuario'] != 'ALUMNO') {
      throw Exception('Solo los alumnos pueden crear tareas');
    }

    final alumno = await supabase
        .from('alumno')
        .select('matricula')
        .eq('idUsuario', perfil['idUsuario'])
        .single();

    final matricula = alumno['matricula'] as String;

    if (titulo.trim().isEmpty) {
      throw Exception('El título es obligatorio');
    }

    if (idMateria <= 0) {
      throw Exception('Selecciona una materia válida');
    }

    final prioridadSQL = prioridad.trim().toUpperCase();

    if (!['ALTA', 'MEDIA', 'BAJA'].contains(prioridadSQL)) {
      throw Exception('Prioridad no válida');
    }

    await supabase.from('tarea').insert({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'prioridad': prioridadSQL,
      'fecha':
          '${fecha.year.toString().padLeft(4, '0')}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}',
      'idMateria': idMateria,
      'color': color,
      'matricula': matricula,
      'completada': false,
    });

    debugPrint('Tarea guardada correctamente en Supabase');
  }

  static Future<int?> obtenerIdMateriaSupabase(String nombre) async {
    final resultado = await Supabase.instance.client
        .from('materia')
        .select('idMateria')
        .ilike('nombre', nombre.trim())
        .limit(1);

    if (resultado.isEmpty) return null;

    return (resultado.first['idMateria'] as num).toInt();
  }

  static Future<List<Map<String, dynamic>>> obtenerNotasSupabase() async {
    final supabase = Supabase.instance.client;

    // 1. Verificar la sesión
    final usuarioAuth = supabase.auth.currentUser;

    if (usuarioAuth == null) {
      throw Exception('No hay un usuario autenticado');
    }

    // 2. Obtener el perfil del usuario
    final perfil = await supabase
        .from('usuario')
        .select('idUsuario, tipoUsuario')
        .eq('auth_uid', usuarioAuth.id)
        .single();

    if (perfil['tipoUsuario'] != 'ALUMNO') {
      throw Exception('La cuenta no corresponde a un alumno');
    }

    // 3. Obtener la matrícula del alumno
    final alumno = await supabase
        .from('alumno')
        .select('matricula')
        .eq('idUsuario', perfil['idUsuario'])
        .single();

    final matricula = alumno['matricula'] as String;

    // 4. Consultar las notas desde PostgreSQL
    final resultado = await supabase
        .from('nota')
        .select('idNota, titulo, contenido, color, fechaCreacion, matricula')
        .eq('matricula', matricula)
        .order('fechaCreacion', ascending: false);

    return List<Map<String, dynamic>>.from(resultado);
  }

  static Future<String> _matriculaNotasAutenticada() async {
    final supabase = Supabase.instance.client;
    final auth = supabase.auth.currentUser;
    if (auth == null) throw StateError('Inicia sesión primero');

    final perfil = await supabase
        .from('usuario')
        .select('idUsuario, tipoUsuario')
        .eq('auth_uid', auth.id)
        .single();
    if (perfil['tipoUsuario'] != 'ALUMNO') {
      throw StateError('Esta cuenta no corresponde a un alumno');
    }
    final alumno = await supabase
        .from('alumno')
        .select('matricula')
        .eq('idUsuario', perfil['idUsuario'])
        .single();
    return alumno['matricula'] as String;
  }

  static String _colorNotaBD(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  static Future<void> guardarNotaSupabase({
    required String titulo,
    required String contenido,
    required Color color,
  }) async {
    if (titulo.trim().isEmpty || contenido.trim().isEmpty) {
      throw ArgumentError('Completa el título y el contenido');
    }
    final matricula = await _matriculaNotasAutenticada();
    await Supabase.instance.client.from('nota').insert({
      'titulo': titulo.trim(),
      'contenido': contenido.trim(),
      'color': _colorNotaBD(color),
      'matricula': matricula,
    });
  }

  static Future<void> actualizarNotaSupabase({
    required int idNota,
    required String titulo,
    required String contenido,
    required Color color,
  }) async {
    if (titulo.trim().isEmpty || contenido.trim().isEmpty) {
      throw ArgumentError('Completa el título y el contenido');
    }
    final matricula = await _matriculaNotasAutenticada();
    final resultado = await Supabase.instance.client
        .from('nota')
        .update({
          'titulo': titulo.trim(),
          'contenido': contenido.trim(),
          'color': _colorNotaBD(color),
        })
        .eq('idNota', idNota)
        .eq('matricula', matricula)
        .select('idNota');
    if (resultado.isEmpty) {
      throw StateError('No se encontró la nota o no tienes permiso');
    }
  }

  static Future<void> eliminarNotaSupabase(int idNota) async {
    final matricula = await _matriculaNotasAutenticada();
    final resultado = await Supabase.instance.client
        .from('nota')
        .delete()
        .eq('idNota', idNota)
        .eq('matricula', matricula)
        .select('idNota');
    if (resultado.isEmpty) {
      throw StateError('No se encontró la nota o no tienes permiso');
    }
  }

  static Future<List<Map<String, dynamic>>>
  obtenerNotificacionesSupabase() async {
    final supabase = Supabase.instance.client;

    final usuarioAuth = supabase.auth.currentUser;

    if (usuarioAuth == null) {
      throw Exception('No hay un usuario autenticado');
    }

    // La función SQL identifica al alumno y
    // recupera únicamente sus notificaciones.
    final resultado = await supabase.rpc('obtener_mis_notificaciones');

    return List<Map<String, dynamic>>.from(resultado);
  }

  static Future<List<Map<String, dynamic>>>
  obtenerMateriasAsesoriaSupabase() async {
    final respuesta = await Supabase.instance.client
        .from('materia')
        .select('idMateria, nombre')
        .order('nombre');
    return List<Map<String, dynamic>>.from(respuesta);
  }

  static Future<List<Map<String, dynamic>>> obtenerProfesoresMateriaSupabase(
    int idMateria,
  ) async {
    final respuesta = await Supabase.instance.client.rpc(
      'profesores_de_materia',
      params: {'p_id_materia': idMateria},
    );
    return List<Map<String, dynamic>>.from(respuesta as List);
  }

  static Future<int> solicitarAsesoriaSupabase({
    required String motivo,
    required int idMateria,
    required String numeroEmpleadoProf,
    required DateTime fecha,
    required TimeOfDay hora,
  }) async {
    final fechaSQL =
        '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
    final horaSQL =
        '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}:00';
    final id = await Supabase.instance.client.rpc(
      'solicitar_asesoria',
      params: {
        'p_motivo': motivo.trim(),
        'p_id_materia': idMateria,
        'p_numero_empleado_prof': numeroEmpleadoProf,
        'p_fecha': fechaSQL,
        'p_hora': horaSQL,
      },
    );
    return (id as num).toInt();
  }

  static Future<List<Map<String, dynamic>>> obtenerAsesoriasSupabase() async {
    final supabase = Supabase.instance.client;
    final usuarioAuth = supabase.auth.currentUser;
    if (usuarioAuth == null) {
      throw Exception('Inicia sesión para consultar tus asesorías');
    }

    final perfil = await supabase
        .from('usuario')
        .select('idUsuario, tipoUsuario')
        .eq('auth_uid', usuarioAuth.id)
        .single();
    if (perfil['tipoUsuario'] != 'ALUMNO') {
      throw Exception(
        'Solo el alumno puede ver sus asesorías en esta pantalla',
      );
    }

    final alumno = await supabase
        .from('alumno')
        .select('matricula')
        .eq('idUsuario', perfil['idUsuario'])
        .single();
    final matricula = alumno['matricula'] as String;

    final respuesta = await supabase
        .from('asesoria')
        .select(
          'idAsesoria, titulo, idMateria, fecha, hora, '
          'nombreCompletoProfesor, nombreCompletoAlumno, estado, origen',
        )
        .eq('matricula', matricula)
        .order('fecha', ascending: false)
        .order('hora', ascending: false);
    return List<Map<String, dynamic>>.from(respuesta);
  }

  // ASESORIAS DEL DOCENTE: consulta solo las asignadas al profesor autenticado.
  // La politica RLS de public.asesoria debe comprobar la identidad en servidor.
  static Future<List<Map<String, dynamic>>>
  obtenerAsesoriasDocenteSupabase() async {
    final supabase = Supabase.instance.client;
    final usuarioAuth = supabase.auth.currentUser;
    if (usuarioAuth == null) {
      throw StateError('Inicia sesion para consultar tus asesorias');
    }

    final perfil = await supabase
        .from('usuario')
        .select('idUsuario, tipoUsuario')
        .eq('auth_uid', usuarioAuth.id)
        .single();
    if (perfil['tipoUsuario'] != 'PROFESOR') {
      throw StateError('Esta cuenta no corresponde a un profesor');
    }

    final profesor = await supabase
        .from('profesor')
        .select('numeroEmpleadoProf')
        .eq('idUsuario', perfil['idUsuario'])
        .single();
    final numeroEmpleado = profesor['numeroEmpleadoProf'] as String;

    final respuesta = await supabase
        .from('asesoria')
        .select(
          'idAsesoria, titulo, idMateria, fecha, hora, '
          'nombreCompletoProfesor, nombreCompletoAlumno, estado, origen',
        )
        .eq('numeroEmpleadoProf', numeroEmpleado)
        .order('fecha', ascending: false)
        .order('hora', ascending: false);

    return List<Map<String, dynamic>>.from(respuesta);
  }

  static Future<List<Map<String, dynamic>>>
  obtenerActividadesDocenteSupabase() async {
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) {
      throw Exception('Debes iniciar sesión');
    }

    final respuesta = await supabase.rpc('soga_docente_consultar_actividades');

    if (respuesta is! List) {
      throw const FormatException(
        'Respuesta inválida al consultar actividades',
      );
    }

    return respuesta
        .map((fila) => Map<String, dynamic>.from(fila as Map))
        .toList();
  }
}
