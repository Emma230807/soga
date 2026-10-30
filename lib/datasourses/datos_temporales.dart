import 'package:flutter/material.dart';
import 'package:soga/models/alumno.dart';
import 'package:soga/models/docente.dart';
import 'package:soga/models/grupo.dart';
import 'package:soga/models/tarea.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/models/vinculacion_docente_alumno.dart';
import 'package:soga/models/asesoria.dart';

class DatosTemporales {
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

  // ==========================================
  // LISTA DE DOCENTES
  // ==========================================

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

  // ALUMNOS ORGANIZADOS POR GRUPO
  static const Map<String, List<Alumno>> alumnosPorGrupo = {
    '3° A · Matemáticas': [
      Alumno(
        codigoAlumno: 'ALU-0002',
        nombre: 'Ana Martínez',
        iniciales: 'AM',
        color: Color(0xFF7648FF),
        tareas: [
          Tarea(titulo: 'Ejercicios de álgebra', fechaEntrega: '20 de octubre'),
          Tarea(
            titulo: 'Problemas de ecuaciones',
            fechaEntrega: '23 de octubre',
          ),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0003',
        nombre: 'Diego Hernández',
        iniciales: 'DH',
        color: Color(0xFFFF754F),
        tareas: [
          Tarea(
            titulo: 'Operaciones con fracciones',
            fechaEntrega: '21 de octubre',
          ),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0004',
        nombre: 'Lucía Torres',
        iniciales: 'LT',
        color: Color(0xFF31CFA1),
        tareas: [
          Tarea(titulo: 'Ecuaciones lineales', fechaEntrega: '20 de octubre'),
          Tarea(titulo: 'Geometría básica', fechaEntrega: '22 de octubre'),
          Tarea(titulo: 'Problemas matemáticos', fechaEntrega: '25 de octubre'),
        ],
      ),
    ],

    '3° B · Matemáticas': [
      Alumno(
        codigoAlumno: 'ALU-0005',
        nombre: 'Carlos López',
        iniciales: 'CL',
        color: Color(0xFF7648FF),
        tareas: [
          Tarea(
            titulo: 'Multiplicación de polinomios',
            fechaEntrega: '24 de octubre',
          ),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0006',
        nombre: 'Sofía Ramírez',
        iniciales: 'SR',
        color: Color(0xFF31CFA1),
        tareas: [
          Tarea(titulo: 'Factorización', fechaEntrega: '25 de octubre'),
          Tarea(titulo: 'Ecuaciones', fechaEntrega: '26 de octubre'),
        ],
      ),
    ],

    '2° A · Física': [
      Alumno(
        codigoAlumno: 'ALU-0007',
        nombre: 'Pedro Sánchez',
        iniciales: 'PS',
        color: Color(0xFFFF754F),
        tareas: [
          Tarea(titulo: 'Leyes de Newton', fechaEntrega: '27 de octubre'),
        ],
      ),
      Alumno(
        codigoAlumno: 'ALU-0008',
        nombre: 'Mariana Gómez',
        iniciales: 'MG',
        color: Color(0xFF7648FF),
        tareas: [
          Tarea(titulo: 'Movimiento rectilíneo', fechaEntrega: '28 de octubre'),
          Tarea(titulo: 'Fuerza y masa', fechaEntrega: '29 de octubre'),
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
}
