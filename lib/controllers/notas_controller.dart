import 'package:flutter/material.dart';
import 'package:soga/models/nota.dart';
import 'package:soga/datasourses/notas_datasource.dart';

class NotasController {
  final NotasDataSource dataSource = NotasDataSource();

  // GUARDAR NOTA
  bool guardarNota(String titulo, String contenido, Color color) {
    // VALIDAR DATOS
    if (titulo.trim().isEmpty || contenido.trim().isEmpty) {
      return false;
    }

    // CREAR NOTA
    Nota nuevaNota = Nota(
      id: dataSource.generarId(),
      titulo: titulo.trim(),
      contenido: contenido.trim(),
      color: color,
      fechaCreacion: DateTime.now(),
    );
    // GUARDAR EN EL DATASOURCE
    dataSource.agregarNota(nuevaNota);

    return true;
  }

  // OBTENER NOTAS
  List<Nota> obtenerNotas() {
    return dataSource.obtenerNotas();
  }
}
