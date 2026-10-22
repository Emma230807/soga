import 'package:flutter/material.dart';
import 'package:soga/models/tarea.dart';

class Alumno {
  final String nombre;
  final String iniciales;
  final Color color;
  final List<Tarea> tareas;
  final String codigoAlumno;

  const Alumno({
    required this.nombre,
    required this.iniciales,
    required this.color,
    required this.tareas,
    this.codigoAlumno = '',
  });

  int get tareasPendientes {
    return tareas.where((tarea) => !tarea.completada).length;
  }
}
