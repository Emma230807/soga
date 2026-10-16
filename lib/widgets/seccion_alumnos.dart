import 'package:flutter/material.dart';

import '../models/alumno.dart';
import 'tarjeta_alumno.dart';

class SeccionAlumnos extends StatelessWidget {
  final List<Alumno> alumnos;
  final int? alumnoAbierto;
  final ValueChanged<int> onAlumnoTap;

  const SeccionAlumnos({
    super.key,
    required this.alumnos,
    required this.alumnoAbierto,
    required this.onAlumnoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALUMNOS',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF858099),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Lun, mié y vie · 08:00',
                  style: TextStyle(fontSize: 10, color: Color(0xFF858099)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEAFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${alumnos.length} alumnos',
                style: const TextStyle(color: Color(0xFF7648FF), fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ListView.builder(
          itemCount: alumnos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return TarjetaAlumno(
              alumno: alumnos[index],
              abierto: alumnoAbierto == index,
              onTap: () => onAlumnoTap(index),
            );
          },
        ),
      ],
    );
  }
}
