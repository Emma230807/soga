
import 'package:flutter/material.dart';

class SelectorProfesor extends StatelessWidget {
  final String? profesorSeleccionado;
  final ValueChanged<String?> onSeleccionar;

  const SelectorProfesor({
    super.key,
    required this.profesorSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final profesores = [
      'Ana López',
      'Carlos Martínez',
      'María Hernández',
      'José Ramírez',
      'Laura Gómez',
    ];

    return DropdownButtonFormField<String>(
      initialValue: profesorSeleccionado,
      hint: const Text("Selecciona un profesor"),

      isExpanded: true,

      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      items: profesores.map((profesor) {
        return DropdownMenuItem<String>(
          value: profesor,
          child: Text(profesor),
        );
      }).toList(),

      onChanged: onSeleccionar,
    );
  }
}
