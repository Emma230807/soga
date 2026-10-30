import 'package:flutter/material.dart';

import '../models/alumno.dart';
import '../models/tarea.dart';

// GRUPOS DEL DOCENTE
const List<String> gruposDocente = [
  '3° A · Matemáticas',
  '3° B · Matemáticas',
  '2° A · Física',
];

// ALUMNOS ORGANIZADOS POR GRUPO

final Map<String, List<Alumno>> alumnosPorGrupo = {
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
