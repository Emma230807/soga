import 'package:flutter/material.dart';

class Asesoria {
  int idAsesoria;
  DateTime fecha;
  TimeOfDay hora;
  String nombreCompletoProfesor;
  String nombreCompletoAlumno;

  Asesoria({
    required this.idAsesoria,
    required this.fecha,
    required this.hora,
    required this.nombreCompletoProfesor,
    required this.nombreCompletoAlumno,
  });
}
