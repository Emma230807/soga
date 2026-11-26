import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soga/models/alumno.dart';
import 'package:soga/models/docente.dart';
import 'package:soga/models/grupo.dart';
import 'package:soga/models/tarea.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/models/vinculacion_docente_alumno.dart';
import 'package:soga/models/asesoria.dart';
import 'package:soga/models/nota.dart';

class DatosTemporales {
  // Sesion vigente en Supabase. Las colecciones locales siguen disponibles
  // temporalmente para las pantallas aun no migradas.
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
          if (administrador['numeroEmpleado'] == null) {
            throw StateError('No se encontro el registro de administrador.');
          }
          break;
        default:
          throw StateError('Rol de usuario no reconocido: $tipo');
      }

      final sesion = UsuarioSesion(
        id: id,
        nombre: perfil['nombreCompleto'] as String,
        correo: perfil['correo'] as String,
        rol: rol,
        matricula: matricula,
        authUid: cuenta.id,
        numeroEmpleadoProf: numeroEmpleadoProf,
      );
      _sesionSupabase = sesion;
      return sesion;
    } catch (_) {
      _sesionSupabase = null;
      await client.auth.signOut();
      rethrow;
    }
  }

  // Adaptador para la pantalla HomeDocente existente. Una vez migrado
  // ese modulo, sus consultas deben usar numeroEmpleadoProf en PostgreSQL.
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
    await Supabase.instance.client.auth.signOut();
    _sesionSupabase = null;
  }

  static Future<void> probarGuardadoTarea() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw Exception('No hay un usuario autenticado en Firebase');
    }

    final referencia = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('tareas')
        .doc('tarea_prueba_1');

    await referencia.set({
      'titulo': 'Primera tarea de SOGA',
      'descripcion': 'Prueba de almacenamiento en Firestore',
      'prioridad': 'Alta',
      'fecha': Timestamp.fromDate(DateTime(2026, 11, 25)),
      'completada': false,
      'matricula': 'ALU-0002',
    });

    final resultado = await referencia.get(
      const GetOptions(source: Source.server),
    );

    if (!resultado.exists) {
      throw Exception('La tarea no se recuperó de Firestore');
    }

    debugPrint('Tarea guardada: ${resultado.data()}');
  }

  static List<Asesoria> asesorias = [
    Asesoria(
      idAsesoria: 1,
      fecha: DateTime(2026, 10, 30),
      hora: const TimeOfDay(hour: 9, minute: 0),
      nombreCompletoProfesor: "Ema Ramírez",
      nombreCompletoAlumno: "Carlos López",
    ),
    Asesoria(
      idAsesoria: 2,
      fecha: DateTime(2026, 10, 30),
      hora: const TimeOfDay(hour: 11, minute: 30),
      nombreCompletoProfesor: "María González",
      nombreCompletoAlumno: "Ana Martínez",
    ),
    Asesoria(
      idAsesoria: 3,
      fecha: DateTime(2026, 11, 2),
      hora: const TimeOfDay(hour: 10, minute: 0),
      nombreCompletoProfesor: "Ema Ramírez",
      nombreCompletoAlumno: "Luis Hernández",
    ),
    Asesoria(
      idAsesoria: 4,
      fecha: DateTime(2026, 11, 3),
      hora: const TimeOfDay(hour: 12, minute: 0),
      nombreCompletoProfesor: "José Pérez",
      nombreCompletoAlumno: "Carlos López",
    ),
    Asesoria(
      idAsesoria: 5,
      fecha: DateTime(2026, 11, 4),
      hora: const TimeOfDay(hour: 8, minute: 30),
      nombreCompletoProfesor: "María González",
      nombreCompletoAlumno: "Sofía Torres",
    ),
    Asesoria(
      idAsesoria: 6,
      fecha: DateTime(2026, 10, 20),
      hora: const TimeOfDay(hour: 9, minute: 30),
      nombreCompletoProfesor: "Ema Ramírez",
      nombreCompletoAlumno: "Ana Martínez",
    ),
    Asesoria(
      idAsesoria: 7,
      fecha: DateTime(2026, 10, 22),
      hora: const TimeOfDay(hour: 13, minute: 0),
      nombreCompletoProfesor: "José Pérez",
      nombreCompletoAlumno: "Diego Sánchez",
    ),
    Asesoria(
      idAsesoria: 8,
      fecha: DateTime(2026, 10, 25),
      hora: const TimeOfDay(hour: 10, minute: 30),
      nombreCompletoProfesor: "María González",
      nombreCompletoAlumno: "Luis Hernández",
    ),
    Asesoria(
      idAsesoria: 9,
      fecha: DateTime(2026, 11, 5),
      hora: const TimeOfDay(hour: 14, minute: 0),
      nombreCompletoProfesor: "Ema Ramírez",
      nombreCompletoAlumno: "Sofía Torres",
    ),
    Asesoria(
      idAsesoria: 10,
      fecha: DateTime(2026, 11, 6),
      hora: const TimeOfDay(hour: 11, minute: 0),
      nombreCompletoProfesor: "José Pérez",
      nombreCompletoAlumno: "Diego Sánchez",
    ),
  ];

  // Notificaciones de prueba compartidas por la aplicación.
  static const List<Map<String, String>> notificaciones = [
    {
      'titulo': 'Nueva tarea asignada',
      'mensaje': 'El profesor de Matemáticas ha asignado una nueva tarea.',
      'fecha': 'Hoy, 10:30 AM',
    },
    {
      'titulo': 'Calificación disponible',
      'mensaje': 'Tu calificación de Programación ya está disponible.',
      'fecha': 'Hoy, 9:15 AM',
    },
    {
      'titulo': 'Asesoría programada',
      'mensaje': 'Tienes una asesoría de Matemáticas programada.',
      'fecha': 'Ayer, 3:45 PM',
    },
    {
      'titulo': 'Recordatorio de tarea',
      'mensaje': 'La tarea de Base de Datos vence mañana.',
      'fecha': 'Ayer, 12:00 PM',
    },
    {
      'titulo': 'Aviso del docente',
      'mensaje': 'El profesor de Desarrollo Móvil publicó un aviso.',
      'fecha': '27 oct, 8:00 AM',
    },
  ];

  // ==========================================
  // LISTA DE DOCENTES
  // ==========================================

  static const List<String> prioridades = ['Alta', 'Media', 'Baja'];

  static const List<Color> coloresNota = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  static final materias = [
    'Matemáticas',
    'Español',
    'Inglés',
    'Programación',
    'Base de datos',
  ];

  static final List<Docente> docentes = [
    Docente(
      id: 1,
      nombre: 'Emma',
      correo: 'emma@gmail.com',
      contrasena: '231606',
    ),
    Docente(
      id: 2,
      nombre: 'María López',
      correo: 'maria@gmail.com',
      contrasena: '123456',
    ),
  ];

  static final List<Grupo> grupos = [
    Grupo(idGrupo: "GTID243", nombreGrupo: 'Desarrollo de Software 3'),
    Grupo(idGrupo: "GTID242", nombreGrupo: 'Desarrollo de Software 2'),
  ];

  // ==========================================
  // CUENTAS DE ALUMNOS Y ADMINISTRADORES
  // ==========================================

  static final Map<String, List<Alumno>> alumnosPorGrupo = {
    '3° A · Matemáticas': [
      Alumno(
        codigoAlumno: 'ALU-0002',
        nombre: 'Ana Martínez',
        iniciales: 'AM',
        color: const Color(0xFF7648FF),
        tareas: [
          Tarea(
            idTarea: 1,
            titulo: 'Ejercicios de álgebra',
            descripcion: 'Resolver ejercicios de álgebra',
            prioridad: 'Alta',
            fecha: DateTime(2026, 10, 20),
            idMateria: 1,
            color: 'Morado',
            matricula: 'ALU-0002',
            alumno: 'Ana Martínez',
            fechaEntrega: '20 de octubre',
            completada: true,
          ),
          Tarea(
            idTarea: 2,
            titulo: 'Problemas de ecuaciones',
            descripcion: 'Resolver problemas de ecuaciones',
            prioridad: 'Media',
            fecha: DateTime(2026, 10, 23),
            idMateria: 1,
            color: 'Morado',
            matricula: 'ALU-0002',
            alumno: 'Ana Martínez',
            fechaEntrega: '23 de octubre',
          ),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0003',
        nombre: 'Diego Hernández',
        iniciales: 'DH',
        color: const Color(0xFFFF754F),
        tareas: [
          Tarea(
            idTarea: 3,
            titulo: 'Operaciones con fracciones',
            descripcion: 'Resolver operaciones con fracciones',
            prioridad: 'Alta',
            fecha: DateTime(2026, 10, 21),
            idMateria: 1,
            color: 'Naranja',
            matricula: 'ALU-0003',
            alumno: 'Diego Hernández',
            fechaEntrega: '21 de octubre',
            completada: true,
          ),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0004',
        nombre: 'Lucía Torres',
        iniciales: 'LT',
        color: const Color(0xFF31CFA1),
        tareas: [
          Tarea(
            idTarea: 4,
            titulo: 'Ecuaciones lineales',
            descripcion: 'Resolver ecuaciones lineales',
            prioridad: 'Media',
            fecha: DateTime(2026, 10, 20),
            idMateria: 1,
            color: 'Verde',
            matricula: 'ALU-0004',
            alumno: 'Lucía Torres',
            fechaEntrega: '20 de octubre',
            completada: true,
          ),
          Tarea(
            idTarea: 5,
            titulo: 'Geometría básica',
            descripcion: 'Realizar ejercicios de geometría',
            prioridad: 'Baja',
            fecha: DateTime(2026, 10, 22),
            idMateria: 1,
            color: 'Verde',
            matricula: 'ALU-0004',
            alumno: 'Lucía Torres',
            fechaEntrega: '22 de octubre',
          ),
          Tarea(
            idTarea: 6,
            titulo: 'Problemas matemáticos',
            descripcion: 'Resolver problemas matemáticos',
            prioridad: 'Alta',
            fecha: DateTime(2026, 10, 25),
            idMateria: 1,
            color: 'Verde',
            matricula: 'ALU-0004',
            alumno: 'Lucía Torres',
            fechaEntrega: '25 de octubre',
          ),
        ],
      ),
    ],

    '3° B · Matemáticas': [
      Alumno(
        codigoAlumno: 'ALU-0005',
        nombre: 'Carlos López',
        iniciales: 'CL',
        color: const Color(0xFF7648FF),
        tareas: [
          Tarea(
            idTarea: 7,
            titulo: 'Multiplicación de polinomios',
            descripcion: 'Resolver multiplicaciones de polinomios',
            prioridad: 'Alta',
            fecha: DateTime(2026, 10, 24),
            idMateria: 1,
            color: 'Morado',
            matricula: 'ALU-0005',
            alumno: 'Carlos López',
            fechaEntrega: '24 de octubre',
          ),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0006',
        nombre: 'Sofía Ramírez',
        iniciales: 'SR',
        color: const Color(0xFF31CFA1),
        tareas: [
          Tarea(
            idTarea: 8,
            titulo: 'Factorización',
            descripcion: 'Resolver ejercicios de factorización',
            prioridad: 'Media',
            fecha: DateTime(2026, 10, 25),
            idMateria: 1,
            color: 'Verde',
            matricula: 'ALU-0006',
            alumno: 'Sofía Ramírez',
            fechaEntrega: '25 de octubre',
          ),
          Tarea(
            idTarea: 9,
            titulo: 'Ecuaciones',
            descripcion: 'Resolver ecuaciones matemáticas',
            prioridad: 'Alta',
            fecha: DateTime(2026, 10, 26),
            idMateria: 1,
            color: 'Verde',
            matricula: 'ALU-0006',
            alumno: 'Sofía Ramírez',
            fechaEntrega: '26 de octubre',
          ),
        ],
      ),
    ],

    '2° A · Física': [
      Alumno(
        codigoAlumno: 'ALU-0007',
        nombre: 'Pedro Sánchez',
        iniciales: 'PS',
        color: const Color(0xFFFF754F),
        tareas: [
          Tarea(
            idTarea: 10,
            titulo: 'Leyes de Newton',
            descripcion: 'Investigar las tres leyes de Newton',
            prioridad: 'Alta',
            fecha: DateTime(2026, 10, 27),
            idMateria: 2,
            color: 'Naranja',
            matricula: 'ALU-0007',
            alumno: 'Pedro Sánchez',
            fechaEntrega: '27 de octubre',
          ),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0008',
        nombre: 'Mariana Gómez',
        iniciales: 'MG',
        color: const Color(0xFF7648FF),
        tareas: [
          Tarea(
            idTarea: 11,
            titulo: 'Movimiento rectilíneo',
            descripcion: 'Resolver ejercicios de movimiento rectilíneo',
            prioridad: 'Media',
            fecha: DateTime(2026, 10, 28),
            idMateria: 2,
            color: 'Morado',
            matricula: 'ALU-0008',
            alumno: 'Mariana Gómez',
            fechaEntrega: '28 de octubre',
            completada: true,
          ),
          Tarea(
            idTarea: 12,
            titulo: 'Fuerza y masa',
            descripcion: 'Resolver problemas de fuerza y masa',
            prioridad: 'Alta',
            fecha: DateTime(2026, 10, 29),
            idMateria: 2,
            color: 'Morado',
            matricula: 'ALU-0008',
            alumno: 'Mariana Gómez',
            fechaEntrega: '29 de octubre',
          ),
        ],
      ),
    ],
  };

  static final List<Map<String, dynamic>> otrasCuentas = [
    {
      'id': 3,
      'nombre': 'Alumno Prueba',
      'correo': 'alumno@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0001',
    },
    {
      'id': 5,
      'nombre': 'Ana Martínez',
      'correo': 'ana@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0002',
    },
    {
      'id': 6,
      'nombre': 'Diego Hernández',
      'correo': 'diego@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0003',
    },
    {
      'id': 7,
      'nombre': 'Lucía Torres',
      'correo': 'lucia@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0004',
    },
    {
      'id': 8,
      'nombre': 'Carlos López',
      'correo': 'carlos@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0005',
    },
    {
      'id': 9,
      'nombre': 'Sofía Ramírez',
      'correo': 'sofia@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0006',
    },
    {
      'id': 10,
      'nombre': 'Pedro Sánchez',
      'correo': 'pedro@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0007',
    },
    {
      'id': 11,
      'nombre': 'Mariana Gómez',
      'correo': 'mariana@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.alumno,
      'codigoAlumno': 'ALU-0008',
    },
    {
      'id': 4,
      'nombre': 'Administrador Prueba',
      'correo': 'admin@gmail.com',
      'contrasena': '123456',
      'rol': RolUsuario.administrador,
    },
  ];

  // ==========================================
  // LISTA DE VINCULACIONES
  // ==========================================

  // VINCULACIONES DE PRUEBA
  static final List<VinculacionDocenteAlumno> vinculaciones = [
    // Emma tiene vinculados a Ana y Diego
    VinculacionDocenteAlumno(idDocente: 1, codigoAlumno: 'ALU-0002'),

    VinculacionDocenteAlumno(idDocente: 1, codigoAlumno: 'ALU-0003'),

    // María tiene vinculada a Lucía
    VinculacionDocenteAlumno(idDocente: 2, codigoAlumno: 'ALU-0004'),
  ];

  // Una fuente de verdad para tareas: las tareas de los grupos y las de prueba.
  // Los IDs 13..17 corresponden a tareas adicionales y no colisionan con 1..12.
  static final List<Tarea> _tareasAdicionales = [
    Tarea(
      idTarea: 13,
      titulo: "Entregar ensayo de Historia",
      descripcion: "Redactar y entregar un ensayo de Historia",
      prioridad: "Alta",
      fecha: DateTime(2026, 11, 8),
      idMateria: 3,
      color: "Morado",
      matricula: "ALU-0002",
      alumno: "Ana Martínez",
      fechaEntrega: "8 nov",
    ),
    Tarea(
      idTarea: 14,
      titulo: "Resolver ejercicios de cálculo",
      descripcion: "Resolver los ejercicios de cálculo",
      prioridad: "Alta",
      fecha: DateTime(2026, 11, 10),
      idMateria: 1,
      color: "Morado",
      matricula: "ALU-0002",
      alumno: "Ana Martínez",
      fechaEntrega: "10 nov",
    ),
    Tarea(
      idTarea: 15,
      titulo: "Preparar presentación de Química",
      descripcion: "Preparar una presentación sobre Química",
      prioridad: "Media",
      fecha: DateTime(2026, 11, 12),
      idMateria: 4,
      color: "Verde",
      matricula: "ALU-0002",
      alumno: "Ana Martínez",
      fechaEntrega: "12 nov",
    ),
    Tarea(
      idTarea: 16,
      titulo: "Revisar apuntes de Literatura",
      descripcion: "Repasar los apuntes de Literatura",
      prioridad: "Baja",
      fecha: DateTime(2026, 11, 13),
      idMateria: 5,
      color: "Azul",
      matricula: "ALU-0002",
      alumno: "Ana Martínez",
      fechaEntrega: "13 nov",
    ),
    Tarea(
      idTarea: 17,
      titulo: "Leer capítulo 1",
      descripcion: "Leer el primer capítulo del libro",
      prioridad: "Media",
      fecha: DateTime(2026, 11, 7),
      idMateria: 3,
      color: "Morado",
      matricula: "ALU-0002",
      alumno: "Ana Martínez",
      fechaEntrega: "7 nov",
      completada: true,
    ),
  ];

  static List<Tarea> obtenerTareas({String? matricula}) {
    final todas = <Tarea>[
      for (final alumnos in alumnosPorGrupo.values)
        for (final alumno in alumnos) ...alumno.tareas,
      ..._tareasAdicionales,
    ];
    if (matricula == null) return todas;
    return todas.where((t) => t.matricula == matricula).toList();
  }

  static bool cambiarEstadoTarea(int idTarea) {
    for (final tarea in obtenerTareas()) {
      if (tarea.idTarea == idTarea) {
        tarea.completada = !tarea.completada;
        return true;
      }
    }
    return false;
  }

  static bool eliminarTarea(int idTarea) {
    final antesAdicionales = _tareasAdicionales.length;
    _tareasAdicionales.removeWhere((t) => t.idTarea == idTarea);
    if (_tareasAdicionales.length != antesAdicionales) return true;
    for (final alumnos in alumnosPorGrupo.values) {
      for (final alumno in alumnos) {
        final antes = alumno.tareas.length;
        alumno.tareas.removeWhere((t) => t.idTarea == idTarea);
        if (alumno.tareas.length != antes) return true;
      }
    }
    return false;
  }

  // Notas de prueba, almacenadas temporalmente en el mismo repositorio.
  static final List<Nota> _notas = [
    Nota(
      id: 1,
      titulo: 'Programación',
      contenido: 'Repasar los widgets de Flutter para el examen.',
      color: const Color(0xFFFFF4B8),
      fechaCreacion: DateTime(2026, 10, 20),
    ),
    Nota(
      id: 2,
      titulo: 'Base de datos',
      contenido: 'Terminar el diagrama entidad-relación.',
      color: const Color(0xFFD5E8FF),
      fechaCreacion: DateTime(2026, 10, 21),
    ),
    Nota(
      id: 3,
      titulo: 'Matemáticas',
      contenido: 'Estudiar los ejercicios de cálculo.',
      color: const Color(0xFFFAD5E4),
      fechaCreacion: DateTime(2026, 10, 22),
    ),
  ];
  static int _siguienteIdNota = 4;
  static int generarIdNota() => _siguienteIdNota++;
  static void agregarNota(Nota nota) => _notas.add(nota);
  static List<Nota> obtenerNotas() => List.unmodifiable(_notas);

  // Grupos compartidos con las pantallas del docente.
  static List<String> get gruposDocente =>
      List.unmodifiable(alumnosPorGrupo.keys);

  // ==========================================
  // VALIDAR DOCENTE
  // ==========================================

  static Docente? validarDocente(String correo, String contrasena) {
    for (Docente docente in docentes) {
      if (docente.correo.toLowerCase() == correo.trim().toLowerCase() &&
          docente.contrasena == contrasena) {
        return docente;
      }
    }

    return null;
  }

  // ==========================================
  // INICIAR SESIÓN
  // ==========================================

  static UsuarioSesion? iniciarSesion(String correo, String contrasena) {
    // Buscar primero entre los docentes
    final docente = validarDocente(correo, contrasena);

    if (docente != null) {
      return UsuarioSesion(
        id: docente.id,
        nombre: docente.nombre,
        correo: docente.correo,
        rol: RolUsuario.docente,
      );
    }

    // Buscar entre alumnos y administradores
    for (final cuenta in otrasCuentas) {
      if (cuenta['correo'].toString().toLowerCase() ==
              correo.trim().toLowerCase() &&
          cuenta['contrasena'] == contrasena) {
        return UsuarioSesion(
          id: cuenta['id'] as int,
          nombre: cuenta['nombre'] as String,
          correo: cuenta['correo'] as String,
          rol: cuenta['rol'] as RolUsuario,
        );
      }
    }

    return null;
  }

  // ==========================================
  // BUSCAR ALUMNO POR CÓDIGO
  // ==========================================

  static Map<String, dynamic>? buscarAlumnoPorCodigo(String codigo) {
    final codigoBuscado = codigo.trim().toUpperCase();

    for (final cuenta in otrasCuentas) {
      if (cuenta['rol'] == RolUsuario.alumno &&
          cuenta['codigoAlumno'] == codigoBuscado) {
        return cuenta;
      }
    }

    return null;
  }

  // ==========================================
  // OBTENER CÓDIGO DEL ALUMNO
  // ==========================================

  static String? obtenerCodigoAlumno(String correo) {
    final sesion = _sesionSupabase;
    if (sesion != null &&
        sesion.rol == RolUsuario.alumno &&
        sesion.correo.toLowerCase() == correo.trim().toLowerCase()) {
      return sesion.matricula;
    }
    for (final cuenta in otrasCuentas) {
      if (cuenta['rol'] == RolUsuario.alumno &&
          cuenta['correo'].toString().toLowerCase() ==
              correo.trim().toLowerCase()) {
        return cuenta['codigoAlumno'] as String?;
      }
    }

    return null;
  }

  // ==========================================
  // SOLICITAR VINCULACIÓN
  // ==========================================

  static bool solicitarVinculacion(int idDocente, String codigoAlumno) {
    final codigo = codigoAlumno.trim().toUpperCase();

    // Verificar que el alumno exista
    final alumno = buscarAlumnoPorCodigo(codigo);

    if (alumno == null) {
      return false;
    }

    // Verificar que el docente exista
    final existeDocente = docentes.any((docente) => docente.id == idDocente);

    if (!existeDocente) {
      return false;
    }

    // Evitar vinculaciones duplicadas
    final existeVinculacion = vinculaciones.any(
      (vinculacion) =>
          vinculacion.idDocente == idDocente &&
          vinculacion.codigoAlumno == codigo &&
          vinculacion.estado != EstadoVinculacion.rechazada,
    );

    if (existeVinculacion) {
      return false;
    }

    // Crear solicitud pendiente
    vinculaciones.add(
      VinculacionDocenteAlumno(idDocente: idDocente, codigoAlumno: codigo)
        ..aceptar(),
    );

    return true;
  }

  // ==========================================
  // ACEPTAR VINCULACIÓN
  // ==========================================

  static bool aceptarVinculacion(int idDocente, String codigoAlumno) {
    final codigo = codigoAlumno.trim().toUpperCase();

    for (final vinculacion in vinculaciones) {
      if (vinculacion.idDocente == idDocente &&
          vinculacion.codigoAlumno == codigo &&
          vinculacion.estado == EstadoVinculacion.pendiente) {
        vinculacion.aceptar();

        return true;
      }
    }

    return false;
  }

  // ==========================================
  // RECHAZAR VINCULACIÓN
  // ==========================================

  static bool rechazarVinculacion(int idDocente, String codigoAlumno) {
    final codigo = codigoAlumno.trim().toUpperCase();

    for (final vinculacion in vinculaciones) {
      if (vinculacion.idDocente == idDocente &&
          vinculacion.codigoAlumno == codigo &&
          vinculacion.estado == EstadoVinculacion.pendiente) {
        vinculacion.rechazar();

        return true;
      }
    }

    return false;
  }

  // ==========================================
  // OBTENER SOLICITUDES PENDIENTES DEL ALUMNO
  // ==========================================

  static List<VinculacionDocenteAlumno> obtenerSolicitudesPendientes(
    String codigoAlumno,
  ) {
    final codigo = codigoAlumno.trim().toUpperCase();

    return vinculaciones
        .where(
          (vinculacion) =>
              vinculacion.codigoAlumno == codigo &&
              vinculacion.estado == EstadoVinculacion.pendiente,
        )
        .toList();
  }

  // ==========================================
  // OBTENER ALUMNOS VINCULADOS A UN DOCENTE
  // ==========================================

  static List<String> obtenerAlumnosVinculados(int idDocente) {
    return vinculaciones
        .where(
          (vinculacion) =>
              vinculacion.idDocente == idDocente && vinculacion.estaAceptada,
        )
        .map((vinculacion) => vinculacion.codigoAlumno)
        .toSet()
        .toList();
  }
  // =====================================================
  // FIRESTORE — PRIMERA ETAPA: TAREAS DEL USUARIO ACTUAL
  // =====================================================
  // Los metodos anteriores permanecen intactos para que la UI existente
  // siga funcionando mientras migramos los controladores a Future/Stream.
  // Requiere sesion REAL de FirebaseAuth, no solo iniciarSesion() local.

  static String get _uidFirebase {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      throw StateError('Inicia sesión en Firebase Authentication primero.');
    }
    return usuario.uid;
  }

  static CollectionReference<Map<String, dynamic>> get _tareasFirestore =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_uidFirebase)
          .collection('tareas');

  static Map<String, dynamic> _tareaParaFirestore(Tarea tarea) => {
    'idTarea': tarea.idTarea,
    'titulo': tarea.titulo,
    'descripcion': tarea.descripcion,
    'prioridad': tarea.prioridad,
    'fecha': Timestamp.fromDate(tarea.fecha),
    'idMateria': tarea.idMateria,
    'color': tarea.color,
    'matricula': tarea.matricula,
    'alumno': tarea.alumno,
    'fechaEntrega': tarea.fechaEntrega,
    'completada': tarea.completada,
  };

  // Importa SOLO las tareas de la matrícula indicada al perfil Firebase
  // autenticado. Úsalo una sola vez durante el desarrollo, sin datos reales.
  // No utilizar para vincular identidades: más adelante la matrícula deberá
  // pertenecer al uid según un perfil validado por el servidor.
  static Future<int> importarTareasDePruebaFirestore({
    required String matricula,
  }) async {
    final tareas = obtenerTareas(matricula: matricula);
    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    for (final tarea in tareas) {
      batch.set(
        _tareasFirestore.doc(tarea.idTarea.toString()),
        _tareaParaFirestore(tarea),
      );
    }
    await batch.commit();
    return tareas.length;
  }

  // Datos crudos de Firestore; un controlador los convertirá a Tarea.
  // Esto evita acoplar toda la UI a la migración de una sola vez.
  static Future<List<Map<String, dynamic>>> obtenerTareasFirestore() async {
    final consulta = await _tareasFirestore.get();
    return consulta.docs
        .map((doc) => {'docId': doc.id, ...doc.data()})
        .toList();
  }

  static Stream<List<Map<String, dynamic>>> observarTareasFirestore() =>
      _tareasFirestore.snapshots().map(
        (consulta) => consulta.docs
            .map((doc) => {'docId': doc.id, ...doc.data()})
            .toList(),
      );

  static Future<void> guardarTareaFirestore(Tarea tarea) async {
    await _tareasFirestore
        .doc(tarea.idTarea.toString())
        .set(_tareaParaFirestore(tarea));
  }

  static Future<void> establecerEstadoTareaFirestore(
    int idTarea,
    bool completada,
  ) async {
    await _tareasFirestore.doc(idTarea.toString()).update({
      'completada': completada,
    });
  }

  static Future<void> eliminarTareaFirestore(int idTarea) async {
    await _tareasFirestore.doc(idTarea.toString()).delete();
  }

  // FIRESTORE: unica fuente para las tareas sincronizadas del usuario Firebase.
  // No se confunden las matriculas con UID: Firestore usa el UID autenticado.
  static Tarea _tareaDesdeDocumento(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final fechaDato = data['fecha'];
    final fecha = fechaDato is Timestamp ? fechaDato.toDate() : DateTime.now();
    return Tarea(
      idTarea: (data['idTarea'] as num?)?.toInt() ?? 0,
      firestoreId: doc.id,
      titulo: data['titulo'] as String? ?? 'Sin titulo',
      descripcion: data['descripcion'] as String? ?? '',
      prioridad: data['prioridad'] as String? ?? 'Media',
      fecha: fecha,
      idMateria: (data['idMateria'] as num?)?.toInt() ?? 0,
      color: data['color'] as String? ?? 'Morado',
      matricula: data['matricula'] as String? ?? '',
      alumno: data['alumno'] as String? ?? '',
      fechaEntrega:
          data['fechaEntrega'] as String? ??
          '${fecha.day}/${fecha.month}/${fecha.year}',
      completada: data['completada'] as bool? ?? false,
    );
  }

  static Stream<List<Tarea>> observarTareasUsuarioFirebase() {
    return _tareasFirestore.snapshots().map((snapshot) {
      final tareas = snapshot.docs.map(_tareaDesdeDocumento).toList();
      tareas.sort((a, b) => a.fecha.compareTo(b.fecha));
      return tareas;
    });
  }

  static Future<void> actualizarEstadoTareaFirebase(Tarea tarea) async {
    final id = tarea.firestoreId ?? tarea.idTarea.toString();
    await _tareasFirestore.doc(id).update({'completada': !tarea.completada});
  }

  static Future<void> borrarTareaFirebase(Tarea tarea) async {
    final id = tarea.firestoreId ?? tarea.idTarea.toString();
    await _tareasFirestore.doc(id).delete();
  }

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
          'nombreCompletoProfesor, nombreCompletoAlumno',
        )
        .eq('matricula', matricula)
        .order('fecha', ascending: false)
        .order('hora', ascending: false);
    return List<Map<String, dynamic>>.from(respuesta);
  }
}
