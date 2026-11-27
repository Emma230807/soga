import 'package:flutter/material.dart';
import 'package:soga/datasourses/materias_supabase.dart';

class SelectorMateria extends StatefulWidget {
  final String? materiaSeleccionada;
  final ValueChanged<String?> onSeleccionar;

  const SelectorMateria({
    super.key,
    required this.materiaSeleccionada,
    required this.onSeleccionar,
  });

  @override
  State<SelectorMateria> createState() => _SelectorMateriaState();
}

class _SelectorMateriaState extends State<SelectorMateria> {
  late Future<List<Map<String, dynamic>>> _consulta;

  @override
  void initState() {
    super.initState();
    _consulta = MateriasSupabase.obtenerMaterias();
  }

  void _recargar() => setState(() {
    _consulta = MateriasSupabase.obtenerMaterias();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _consulta,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Row(
            children: [
              const Expanded(child: Text('No se pudieron cargar las materias')),
              IconButton(onPressed: _recargar, icon: const Icon(Icons.refresh)),
            ],
          );
        }
        final materias =
            (snapshot.data ?? [])
                .map((m) => (m['nombre'] ?? '').toString().trim())
                .where((nombre) => nombre.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final elegida = materias.contains(widget.materiaSeleccionada)
            ? widget.materiaSeleccionada
            : null;
        return DropdownButtonFormField<String>(
          key: ValueKey('${widget.materiaSeleccionada}:${materias.join('|')}'),
          initialValue: elegida,
          isExpanded: true,
          hint: Text(
            snapshot.connectionState == ConnectionState.done
                ? 'Selecciona una materia'
                : 'Cargando materias...',
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: materias
              .map(
                (nombre) => DropdownMenuItem(
                  value: nombre,
                  child: Text(nombre, overflow: TextOverflow.ellipsis),
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
