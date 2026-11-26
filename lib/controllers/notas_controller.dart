import 'package:flutter/material.dart';
import 'package:soga/models/nota.dart';
import 'package:soga/datasourses/datos_temporales.dart';

class NotasController {

  // GUARDAR NOTA
  bool guardarNota(String titulo, String contenido, Color color) {
    // VALIDAR DATOS
    if (titulo.trim().isEmpty || contenido.trim().isEmpty) {
      return false;
    }

    // CREAR NOTA
    Nota nuevaNota = Nota(
      id: DatosTemporales.generarIdNota(),
      titulo: titulo.trim(),
      contenido: contenido.trim(),
      color: color,
      fechaCreacion: DateTime.now(),
    );
    // GUARDAR EN EL DATASOURCE
    DatosTemporales.agregarNota(nuevaNota);

    return true;
  }

  // OBTENER NOTAS
  List<Nota> obtenerNotas() {
    return DatosTemporales.obtenerNotas();
  }
}
