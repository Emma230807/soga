import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/usuario_sesion.dart';

class SelectorAlumno extends StatelessWidget {
  final String? alumnoSeleccionado;
  final ValueChanged<String?> onSeleccionar;

  const SelectorAlumno({
    super.key,
    required this.alumnoSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final alumnos = DatosTemporales.otrasCuentas
        .where((cuenta) => cuenta['rol'] == RolUsuario.alumno)
        .toList();

    return DropdownButtonFormField<String>(
      initialValue: alumnoSeleccionado,

      hint: const Text("Selecciona un alumno"),

      isExpanded: true,

      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      items: alumnos.map((alumno) {
        return DropdownMenuItem<String>(
          value: alumno['codigoAlumno'] as String,
          child: Text(alumno['nombre'] as String),
        );
      }).toList(),

      onChanged: onSeleccionar,
    );
  }
}
