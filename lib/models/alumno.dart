import 'package:flutter/material.dart';

import 'tarea.dart';

class Alumno {
  final String nombre;
  final String iniciales;
  final Color color;
  final List<Tarea> tareas;

  const Alumno({
    required this.nombre,
    required this.iniciales,
    required this.color,
    required this.tareas,
  });

  int get tareasPendientes {
    return tareas.where((tarea) => !tarea.completada).length;
  }
}
