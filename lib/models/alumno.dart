import 'package:flutter/material.dart';

class Alumno {
  final String nombre;
  final String iniciales;
  final int tareasPendientes;
  final Color color;

  const Alumno({
    required this.nombre,
    required this.iniciales,
    required this.tareasPendientes,
    required this.color,
  });
}
