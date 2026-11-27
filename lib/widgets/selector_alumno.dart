import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Muestra solo alumnos de grupos/materias asignados al docente autenticado.
/// El valor seleccionado sigue siendo la matrícula, como en el selector anterior.
class SelectorAlumno extends StatefulWidget {
  final String? alumnoSeleccionado;
  final ValueChanged<String?> onSeleccionar;

  const SelectorAlumno({
    super.key,
    required this.alumnoSeleccionado,
    required this.onSeleccionar,
  });

  @override
  State<SelectorAlumno> createState() => _SelectorAlumnoState();
}

class _SelectorAlumnoState extends State<SelectorAlumno> {
  late Future<List<Map<String, dynamic>>> _consulta;

  @override
  void initState() {
    super.initState();
    _consulta = _obtenerAlumnos();
  }

  Future<List<Map<String, dynamic>>> _obtenerAlumnos() async {
    final respuesta = await Supabase.instance.client.rpc(
      'soga_docente_alumnos',
    );
    if (respuesta is! List) {
      throw const FormatException('No se recibió una lista de alumnos');
    }
    return respuesta
        .map((fila) => Map<String, dynamic>.from(fila as Map))
        .toList();
  }

  void _recargar() => setState(() {
    _consulta = _obtenerAlumnos();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _consulta,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Row(
            children: [
              const Expanded(child: Text('No se pudieron cargar los alumnos')),
              IconButton(onPressed: _recargar, icon: const Icon(Icons.refresh)),
            ],
          );
        }
        final nombresPorMatricula = <String, String>{};
        for (final fila in snapshot.data ?? <Map<String, dynamic>>[]) {
          final matricula = (fila['matricula'] ?? '').toString();
          final nombre = (fila['nombre'] ?? '').toString();
          if (matricula.isNotEmpty) {
            nombresPorMatricula[matricula] = nombre.isEmpty
                ? matricula
                : nombre;
          }
        }
        final matriculas = nombresPorMatricula.keys.toList()
          ..sort(
            (a, b) =>
                nombresPorMatricula[a]!.compareTo(nombresPorMatricula[b]!),
          );
        final elegido =
            nombresPorMatricula.containsKey(widget.alumnoSeleccionado)
            ? widget.alumnoSeleccionado
            : null;
        return DropdownButtonFormField<String>(
          key: ValueKey('${widget.alumnoSeleccionado}:${matriculas.join('|')}'),
          initialValue: elegido,
          hint: Text(
            snapshot.connectionState == ConnectionState.done
                ? 'Selecciona un alumno'
                : 'Cargando alumnos...',
          ),
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: matriculas
              .map(
                (matricula) => DropdownMenuItem(
                  value: matricula,
                  child: Text(
                    nombresPorMatricula[matricula]!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: snapshot.connectionState == ConnectionState.done
              ? widget.onSeleccionar
              : null,
        );
      },
    );
  }
}
