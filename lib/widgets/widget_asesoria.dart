import 'package:flutter/material.dart';
import 'package:soga/widgets/selector_fecha.dart';
import 'package:soga/widgets/selector_hora.dart';
import 'package:soga/widgets/selector_materia.dart';
import 'package:soga/widgets/selector_profesor.dart';

class WidgetAsesoria extends StatefulWidget {
  const WidgetAsesoria({super.key});

  @override
  State<WidgetAsesoria> createState() => _WidgetAsesoria();
}

class _WidgetAsesoria extends State<WidgetAsesoria> {
  String? materiaSeleccionada;
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  String? profesorSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Agenda tu asesoría",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                IconButton(
                  color: const Color(0xFF7043FF),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromARGB(100, 214, 202, 252),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // TÍTULO
            const Text("Título", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            TextField(
              decoration: InputDecoration(
                hintText: "Motivo de tu asesoría",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // MATERIA
            const Text(
              "Materia",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            SelectorMateria(
              materiaSeleccionada: materiaSeleccionada,
              onSeleccionar: (materia) {
                setState(() {
                  materiaSeleccionada = materia;
                });
              },
            ),

            const SizedBox(height: 15),
            const Text(
              "Profesor",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            SelectorProfesor(
              profesorSeleccionado: profesorSeleccionado,
              onSeleccionar: (profesor) {
                setState(() {
                  profesorSeleccionado = profesor;
                });
              },
            ),

            // FECHA Y HORA
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Fecha",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      SelectorFecha(
                        fechaSeleccionada: fechaSeleccionada,
                        onSeleccionar: (fecha) {
                          setState(() {
                            fechaSeleccionada = fecha;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hora",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      SelectorHora(
                        horaSeleccionada: horaSeleccionada,
                        onSeleccionar: (hora) {
                          setState(() {
                            horaSeleccionada = hora;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // BOTÓN AGENDAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7043FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Solicitar asesoría",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
