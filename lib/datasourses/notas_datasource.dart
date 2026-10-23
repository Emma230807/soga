import 'package:flutter/material.dart';
import 'package:soga/models/nota.dart';

class NotasDataSource {
  static final List<Nota> _notas = [
    Nota(
      id: 1,
      titulo: "Programación",
      contenido: "Repasar los widgets de Flutter para el examen.",
      color: const Color(0xFFFFF4B8),
      fechaCreacion: DateTime(2026, 10, 20),
    ),
    Nota(
      id: 2,
      titulo: "Base de datos",
      contenido: "Terminar el diagrama entidad-relación.",
      color: const Color(0xFFD5E8FF),
      fechaCreacion: DateTime(2026, 10, 21),
    ),
    Nota(
      id: 3,
      titulo: "Matemáticas",
      contenido: "Estudiar los ejercicios de cálculo.",
      color: const Color(0xFFFAD5E4),
      fechaCreacion: DateTime(2026, 10, 22),
    ),
  ];

  static int _siguienteId = 4;

  // GENERAR ID
  int generarId() {
    return _siguienteId++;
  }

  // AGREGAR NOTA
  void agregarNota(Nota nota) {
    _notas.add(nota);
  }

  // OBTENER NOTAS
  List<Nota> obtenerNotas() {
    return List.from(_notas);
  }
}