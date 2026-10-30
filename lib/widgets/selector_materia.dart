import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';

class SelectorMateria extends StatelessWidget {
  final String? materiaSeleccionada;
  final ValueChanged<String?> onSeleccionar;

  const SelectorMateria({
    super.key,
    required this.materiaSeleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final materias = DatosTemporales.materias;

    return DropdownButtonFormField<String>(
      initialValue: materiaSeleccionada,
      hint: Text("Selecciona una materia"),

      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      items: materias.map((materia) {
        return DropdownMenuItem<String>(value: materia, child: Text(materia));
      }).toList(),

      onChanged: onSeleccionar,
    );
  }
}
