import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/models/alumno.dart';

class PuntuacionAlumnos extends StatefulWidget {
  const PuntuacionAlumnos({super.key});

  @override
  State<PuntuacionAlumnos> createState() => _PuntuacionAlumnos();
}

class _PuntuacionAlumnos extends State<PuntuacionAlumnos> {
  @override
  Widget build(BuildContext context) {
    // OBTENER TODOS LOS ALUMNOS
    final List<Alumno> alumnos = DatosTemporales.alumnosPorGrupo.values
        .expand((grupo) => grupo)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: Column(
        children: [
          EncabezadoSoga(titulo: "Puntuación de alumnos", accion: ""),

          Expanded(
            child: alumnos.isEmpty
                ? const Center(
                    child: Text(
                      "No hay alumnos registrados",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alumnos.length,
                    itemBuilder: (context, index) {
                      final alumno = alumnos[index];

                      final total = alumno.tareas.length;

                      final completadas = alumno.tareas
                          .where((tarea) => tarea.completada)
                          .length;

                      final progreso = total == 0 ? 0.0 : completadas / total;

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: alumno.color,
                                    child: Text(
                                      alumno.iniciales,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      alumno.nombre,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              Text(
                                "$completadas de $total tareas completadas",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progreso,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFECE9FF),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.deepPurple,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
