import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/widgets/selector_alumno.dart';
import 'package:soga/widgets/selector_fecha.dart';
import 'package:soga/widgets/selector_hora.dart';

class RegistroAsesorias extends StatefulWidget {
  const RegistroAsesorias({super.key});

  @override
  State<StatefulWidget> createState() => _RegistroAsesorias();
}

class _RegistroAsesorias extends State<RegistroAsesorias> {
  final docentes = DatosTemporales.docentes;
  String? alumnoSeleccionado;

  DateTime? fechaSeleccionada;

  TimeOfDay? horaSeleccionada;

  @override
  Widget build(BuildContext context) {
    String? profSeleccionado;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoSoga(
              titulo: "Generar asesoria",
              accion: "Registra una nueva asesoria",
            ),

            // CUERPO DEL FORMULARIO
            Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la asesoria',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profesor',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: profSeleccionado,
                          hint: const Text("Selecciona un Profesor"),
                          isExpanded: true,

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.menu_book,
                              color: Colors.deepPurple,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),

                          items: docentes.map((docente) {
                            return DropdownMenuItem<String>(
                              value: docente.nombre,
                              child: Text(docente.nombre),
                            );
                          }).toList(),

                          onChanged: (valor) {
                            setState(() {
                              profSeleccionado = valor;
                            });
                          },
                        ),

                        const SizedBox(height: 30),

                        SelectorAlumno(
                          alumnoSeleccionado: alumnoSeleccionado,
                          onSeleccionar: (valor) {
                            setState(() {
                              alumnoSeleccionado = valor;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Fecha",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hora",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                  const SizedBox(height: 30),

                  // BOTÓN GUARDAR - SIN FUNCIONALIDAD
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton.icon(
                      onPressed: () {},

                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar asesoria'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7140FF),
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
