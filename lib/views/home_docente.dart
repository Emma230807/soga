import 'package:flutter/material.dart';
import 'package:soga/models/datos_docente.dart';

import '../widgets/encabezado_docente.dart';
import '../widgets/selector_grupo.dart';
import '../widgets/seccion_alumnos.dart';

class HomeDocente extends StatefulWidget {
  const HomeDocente({super.key});

  @override
  State<HomeDocente> createState() => _HomeDocenteState();
}

class _HomeDocenteState extends State<HomeDocente> {
  String grupoSeleccionado = gruposDocente.first;
  int? alumnoAbierto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: Column(
        children: [
          const EncabezadoDocente(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
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

                  const SizedBox(height: 22),

                  SeccionAlumnos(
                    alumnos: alumnosDocente,
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
