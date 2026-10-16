import 'package:flutter/material.dart';

import '../models/alumno.dart';

const List<String> gruposDocente = [
  '3° A · Matemáticas',
  '3° B · Matemáticas',
  '2° A · Física',
];

const List<Alumno> alumnosDocente = [
  Alumno(
    nombre: 'Ana Martínez',
    iniciales: 'AM',
    tareasPendientes: 2,
    color: Color(0xFF7648FF),
  ),
  Alumno(
    nombre: 'Diego Hernández',
    iniciales: 'DH',
    tareasPendientes: 1,
    color: Color(0xFFFF754F),
  ),
  Alumno(
    nombre: 'Lucía Torres',
    iniciales: 'LT',
    tareasPendientes: 3,
    color: Color(0xFF31CFA1),
  ),
];
