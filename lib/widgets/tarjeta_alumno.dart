import 'package:flutter/material.dart';

import '../models/alumno.dart';
import 'item_tarea.dart';

class TarjetaAlumno extends StatelessWidget {
  final Alumno alumno;
  final bool abierto;
  final VoidCallback onTap;

  const TarjetaAlumno({
    super.key,
    required this.alumno,
    required this.abierto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2DEEC)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: alumno.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alumno.iniciales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alumno.nombre,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF241D36),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${alumno.tareasPendientes} '
                          '${alumno.tareasPendientes == 1 ? 'tarea pendiente' : 'tareas pendientes'}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF858099),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0ECFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      abierto
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF7648FF),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (abierto)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),

                  const SizedBox(height: 8),

                  const Text(
                    'TAREAS PENDIENTES',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF858099),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...alumno.tareas
                      .where((tarea) => !tarea.completada)
                      .map((tarea) => ItemTarea(tarea: tarea)),

                  if (alumno.tareasPendientes == 0)
                    const Text(
                      'No hay tareas pendientes',
                      style: TextStyle(fontSize: 12, color: Color(0xFF858099)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
