import 'package:soga/datasourses/grupos_supabase.dart';
import 'package:soga/datasourses/materias_supabase.dart';
import 'package:soga/datasourses/profesores_supabase.dart';
import 'package:soga/models/grupo.dart';
import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/datasourses/inscripciones_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaAgregarInscripcion extends StatefulWidget {
  const PantallaAgregarInscripcion({super.key});

  @override
  State<PantallaAgregarInscripcion> createState() =>
      _PantallaAgregarInscripcionState();
}

class _PantallaAgregarInscripcionState
    extends State<PantallaAgregarInscripcion> {
  int? materiaSeleccionada;
  String? profesorSeleccionado;
  String? grupoSeleccionado;

  List<Map<String, dynamic>> docentes = [];
  List<Map<String, dynamic>> materias = [];
  List<Grupo> grupos = [];

  bool cargando = true;
  bool guardando = false;

  String? errorDatos;
  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final listaGrupos = await GruposSupabase.obtenerGrupos();

      final listaMaterias = await MateriasSupabase.obtenerMaterias();

      final listaDocentes = await ProfesoresSupabase.obtenerProfesores();

      if (!mounted) return;

      setState(() {
        grupos = listaGrupos;
        materias = listaMaterias;
        docentes = listaDocentes;
        cargando = false;
        errorDatos = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        errorDatos = 'Error al cargar los datos';
      });

      debugPrint('Error: $e');
      mostrarMensaje(errorDatos!);
    }
  }

  Future<void> guardarInscripcion() async {
    if (guardando || cargando) return;

    if (materiaSeleccionada == null ||
        profesorSeleccionado == null ||
        grupoSeleccionado == null) {
      mostrarMensaje('Selecciona todos los campos');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await InscripcionesSupabase.registrarAsignacion(
        idMateria: materiaSeleccionada!,
        numeroEmpleado: profesorSeleccionado!,
        idGrupo: grupoSeleccionado!,
      );

      if (!mounted) return;

      mostrarMensaje('Inscripción registrada correctamente');
    } on PostgrestException catch (e) {
      if (!mounted) return;

      mostrarMensaje('Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;

      mostrarMensaje('Error al registrar la inscripción');
      debugPrint('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
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

                        DropdownButtonFormField<int>(
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
                            return DropdownMenuItem<int>(
                              value: materia['idMateria'],
                              child: Text(materia['nombre']),
                            );
                          }).toList(),

                          onChanged: cargando || guardando
                              ? null
                              : (valor) {
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
                          initialValue: profesorSeleccionado,
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
                              value: docente['numeroEmpleadoProf'],
                              child: Text(docente['nombre']),
                            );
                          }).toList(),

                          onChanged: cargando || guardando
                              ? null
                              : (valor) {
                                  setState(() {
                                    profesorSeleccionado = valor;
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
                          initialValue: grupoSeleccionado,
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

                          onChanged: cargando || guardando
                              ? null
                              : (valor) {
                                  setState(() {
                                    grupoSeleccionado = valor;
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
                      onPressed: guardando || cargando || errorDatos != null
                          ? null
                          : guardarInscripcion,

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
