import 'package:flutter/material.dart';

import '../models/alumno.dart';
import '../models/tarea.dart';

const List<String> gruposDocente = [
  '3° A · Matemáticas',
  '3° B · Matemáticas',
  '2° A · Física',
];

const Map<String, List<Alumno>> alumnosPorGrupo = {
  '3° A · Matemáticas': [
    Alumno(
      nombre: 'Ana Martínez',
      iniciales: 'AM',
      color: Color(0xFF7648FF),
      tareas: [
        Tarea(titulo: 'Ejercicios de álgebra', fechaEntrega: '20 de octubre'),
        Tarea(titulo: 'Problemas de ecuaciones', fechaEntrega: '23 de octubre'),
      ],
    ),
    Alumno(
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
      nombre: 'Pedro Sánchez',
      iniciales: 'PS',
      color: Color(0xFFFF754F),
      tareas: [Tarea(titulo: 'Leyes de Newton', fechaEntrega: '27 de octubre')],
    ),
    Alumno(
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
