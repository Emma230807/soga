import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/encabezado_soga.dart';

class PantallaAgregarInscripcion extends StatefulWidget {
  const PantallaAgregarInscripcion({super.key});

  @override
  State<PantallaAgregarInscripcion> createState() =>
      _PantallaAgregarInscripcionState();
}

class _PantallaAgregarInscripcionState
    extends State<PantallaAgregarInscripcion> {
  String? materiaSeleccionada;

  final docentes = DatosTemporales.docentes;

  final grupos = DatosTemporales.grupos;

  final List<String> materias = [
    'Matemáticas',
    'Programación',
    'Base de Datos',
    'Inglés',
  ];

  @override
  Widget build(BuildContext context) {
    String? materiaSeleccionada;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoSoga(
              titulo: "Agregar inscripcion",
              accion: "Registra una nueva inscripcion",
            ),

            // CUERPO DEL FORMULARIO
            Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la inscripcion',
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
                        // NOMBRE
                        const Text(
                          'Materia',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: materiaSeleccionada,
                          hint: const Text("Selecciona una materia"),
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

                          items: materias.map((materia) {
                            return DropdownMenuItem<String>(
                              value: materia,
                              child: Text(materia),
                            );
                          }).toList(),

                          onChanged: (valor) {
                            setState(() {
                              materiaSeleccionada = valor;
                            });
                          },
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Profesor',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: materiaSeleccionada,
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
                              materiaSeleccionada = valor;
                            });
                          },
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Grupo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: materiaSeleccionada,
                          hint: const Text("Selecciona un Grupo"),
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

                          items: grupos.map((grupo) {
                            return DropdownMenuItem<String>(
                              value: grupo.idGrupo,
                              child: Text(
                                "${grupo.idGrupo} ${grupo.nombreGrupo}",
                              ),
                            );
                          }).toList(),

                          onChanged: (valor) {
                            setState(() {
                              materiaSeleccionada = valor;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BOTÓN GUARDAR - SIN FUNCIONALIDAD
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton.icon(
                      onPressed: () {},

                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar inscripcion'),

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
