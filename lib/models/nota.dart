import 'package:flutter/material.dart';

class Nota {
  final int id;
  String titulo;
  String contenido;
  Color color;
  DateTime fechaCreacion;

  Nota({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.color,
    required this.fechaCreacion,
  });
}