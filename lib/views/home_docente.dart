
import 'package:flutter/material.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/views/historial_asesorias.dart';
import 'package:soga/views/puntuacion_alumnos.dart';
import 'package:soga/views/registro_asesorias.dart';
import 'package:soga/views/perfil.dart';

import '../models/docente.dart';
import '../datasourses/datos_docente.dart';
import '../datasourses/datos_temporales.dart';

import '../widgets/encabezado_docente.dart';
import '../widgets/selector_grupo.dart';
import '../widgets/seccion_alumnos.dart';
import '../widgets/formulario_vinculacion.dart';

class HomeDocente extends StatefulWidget {
  final Docente docente;
  final UsuarioSesion usuario;

  const HomeDocente({
    super.key,
    required this.docente,
    required this.usuario,
  });

  @override
  State<HomeDocente> createState() => _HomeDocenteState();
}

class _HomeDocenteState extends State<HomeDocente> {
  String grupoSeleccionado = gruposDocente.first;
  int? alumnoAbierto;

  // ABRIR PERFIL
  void abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPerfil(
          usuario: widget.usuario,
        ),
      ),
    );
  }

  // ABRIR REGISTRO DE ASESORÍAS
  void abrirRegistroAsesorias() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroAsesorias(),
      ),
    );
  }

  // ABRIR HISTORIAL DE ASESORÍAS
  void abrirHistorialAsesorias() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialAsesorias(),
      ),
    );
  }

  // ABRIR PUNTUACIÓN DE ALUMNOS
  void abrirPuntuacionAlumnos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuntuacionAlumnos(),
      ),
    );
  }

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
        const SnackBar(
          content: Text('Alumno vinculado correctamente'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El código no existe o el alumno ya está vinculado',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // MOSTRAR LOS ALUMNOS DE PRUEBA DEL GRUPO
    final alumnosActuales =
        alumnosPorGrupo[grupoSeleccionado] ?? [];

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

                  // BOTÓN MI PERFIL
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: abrirPerfil,

                      icon: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.deepPurple,
                      ),

                      label: const Text(
                        "Mi perfil",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.deepPurple,
                        ),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SECCIÓN ASESORÍAS
                  const Text(
                    'ASESORIAS',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.3,
                      color: Color(0xFF858099),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // REGISTRAR ASESORÍA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: abrirRegistroAsesorias,

                      icon: const Icon(Icons.person_add),

                      label: const Text('Registrar asesoria'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7648FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // HISTORIAL DE ASESORÍAS
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: abrirHistorialAsesorias,

                      icon: const Icon(Icons.history),

                      label: const Text('Historial de asesorias'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7648FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

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
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // SECCIÓN PUNTUACIÓN
                  const Text(
                    'Puntaje',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.3,
                      color: Color(0xFF858099),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BOTÓN PUNTUACIÓN DE ALUMNOS
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: abrirPuntuacionAlumnos,

                      icon: const Icon(Icons.bar_chart),

                      label: const Text('Puntajes de alumnos'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7648FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
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
                        alumnoAbierto =
                            alumnoAbierto == index ? null : index;
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
