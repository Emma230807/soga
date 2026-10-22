import 'package:flutter/material.dart';

import '../models/docente.dart';
import '../datasourses/datos_docente.dart';
import '../datasourses/datos_temporales.dart';

import '../widgets/encabezado_docente.dart';
import '../widgets/selector_grupo.dart';
import '../widgets/seccion_alumnos.dart';
import '../widgets/formulario_vinculacion.dart';

class HomeDocente extends StatefulWidget {
  final Docente docente;

  const HomeDocente({super.key, required this.docente});

  @override
  State<HomeDocente> createState() => _HomeDocenteState();
}

class _HomeDocenteState extends State<HomeDocente> {
  String grupoSeleccionado = gruposDocente.first;
  int? alumnoAbierto;

  // ABRIR FORMULARIO PARA AGREGAR ALUMNO
  Future<void> abrirFormularioVinculacion() async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (context) {
        return const FormularioVinculacion();
      },
    );

    if (!mounted || codigo == null) {
      return;
    }

    final agregado = DatosTemporales.solicitarVinculacion(
      widget.docente.id,
      codigo,
    );

    if (!mounted) return;

    if (agregado) {
      setState(() {
        alumnoAbierto = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alumno vinculado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El código no existe o el alumno ya está vinculado'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // MOSTRAR LOS ALUMNOS DE PRUEBA DEL GRUPO
    final alumnosActuales = alumnosPorGrupo[grupoSeleccionado] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      body: Column(
        children: [
          // ENCABEZADO DOCENTE
          EncabezadoDocente(docente: widget.docente),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SELECTOR DE GRUPOS
                  SelectorGrupo(
                    grupos: gruposDocente,
                    grupoSeleccionado: grupoSeleccionado,

                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          grupoSeleccionado = valor;
                          alumnoAbierto = null;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  // BOTÓN AGREGAR ALUMNO
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: abrirFormularioVinculacion,

                      icon: const Icon(Icons.person_add),

                      label: const Text('Agregar alumno'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7648FF),
                        foregroundColor: Colors.white,

                        padding: const EdgeInsets.symmetric(vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // SECCIÓN ORIGINAL DE ALUMNOS
                  SeccionAlumnos(
                    alumnos: alumnosActuales,
                    alumnoAbierto: alumnoAbierto,

                    onAlumnoTap: (index) {
                      setState(() {
                        alumnoAbierto = alumnoAbierto == index ? null : index;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
