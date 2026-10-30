import 'package:flutter/material.dart';
import 'package:soga/models/asesoria.dart';

class TarjetaAsesoria extends StatelessWidget {
  final Asesoria asesoria;

  const TarjetaAsesoria({super.key, required this.asesoria});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Colors.deepPurple, size: 26),
                const SizedBox(width: 10),
                const Text(
                  "Asesoría académica",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              "Profesor: ${asesoria.nombreCompletoProfesor}",
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 8),

            Text(
              "Alumno: ${asesoria.nombreCompletoAlumno}",
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 12),

            const Divider(),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "${asesoria.fecha.day}/${asesoria.fecha.month}/${asesoria.fecha.year}",
                  style: const TextStyle(fontSize: 14),
                ),

                const Spacer(),

                const Icon(
                  Icons.access_time,
                  color: Colors.deepPurple,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  asesoria.hora.format(context),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
