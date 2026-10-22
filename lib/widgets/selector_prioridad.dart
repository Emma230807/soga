import 'package:flutter/material.dart';

class SelectorPrioridad extends StatelessWidget {
  final String prioridadSeleccionada;
  final ValueChanged<String> onSeleccionar;

  const SelectorPrioridad({
    super.key,
    required this.prioridadSeleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final prioridades = ['Alta', 'Media', 'Baja'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: prioridades.map((prioridad) {
        final seleccionada = prioridad == prioridadSeleccionada;

        Color color;

        if (prioridad == 'Alta') {
          color = Colors.redAccent;
        } else if (prioridad == 'Media') {
          color = Colors.amber;
        } else {
          color = Colors.green;
        }

        return ChoiceChip(
          label: Text(prioridad),
          selected: seleccionada,
          onSelected: (_) => onSeleccionar(prioridad),
          selectedColor: color,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: seleccionada ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }
}
