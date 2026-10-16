import 'package:flutter/material.dart';

class SelectorGrupo extends StatelessWidget {
  final String grupoSeleccionado;
  final List<String> grupos;
  final ValueChanged<String?> onChanged;

  const SelectorGrupo({
    super.key,
    required this.grupoSeleccionado,
    required this.grupos,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GRUPO ASIGNADO',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.3,
            color: Color(0xFF858099),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF7648FF)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: grupoSeleccionado,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF7648FF),
              ),
              items: grupos.map((grupo) {
                return DropdownMenuItem<String>(
                  value: grupo,
                  child: Text(
                    grupo,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF241D36),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
