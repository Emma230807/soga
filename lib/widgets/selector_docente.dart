import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';

class SelectorDocente extends StatelessWidget {
  final String? docenteseleccionada;
  final ValueChanged<String?> onSeleccionar;

  const SelectorDocente({
    super.key,
    required this.docenteseleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final docentes = DatosTemporales.docentes;

    return DropdownButtonFormField<String>(
      initialValue: docenteseleccionada,
      hint: Text("Selecciona un profesor"),

      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      items: docentes.map((docente) {
        return DropdownMenuItem<String>(
          value: docente.nombre,
          child: Text(docente.nombre),
        );
      }).toList(),

      onChanged: onSeleccionar,
    );
  }
}
