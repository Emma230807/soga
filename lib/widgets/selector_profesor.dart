import 'package:flutter/material.dart';
import 'package:soga/datasourses/profesores_supabase.dart';

class SelectorProfesor extends StatefulWidget {
  final String? profesorSeleccionado;
  final ValueChanged<String?> onSeleccionar;

  const SelectorProfesor({
    super.key,
    required this.profesorSeleccionado,
    required this.onSeleccionar,
  });

  @override
  State<SelectorProfesor> createState() => _SelectorProfesorState();
}

class _SelectorProfesorState extends State<SelectorProfesor> {
  late Future<List<Map<String, dynamic>>> _consulta;

  @override
  void initState() {
    super.initState();
    _consulta = ProfesoresSupabase.obtenerProfesores();
  }

  void _recargar() {
    setState(() => _consulta = ProfesoresSupabase.obtenerProfesores());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _consulta,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Row(
            children: [
              const Expanded(
                child: Text('No se pudieron cargar los profesores'),
              ),
              IconButton(
                tooltip: 'Reintentar',
                onPressed: _recargar,
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
        }

        final nombres =
            (snapshot.data ?? [])
                .map((p) => (p['nombre'] ?? '').toString().trim())
                .where((nombre) => nombre.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final elegido = nombres.contains(widget.profesorSeleccionado)
            ? widget.profesorSeleccionado
            : null;

        return DropdownButtonFormField<String>(
          key: ValueKey('${widget.profesorSeleccionado}:${nombres.join('|')}'),
          initialValue: elegido,
          isExpanded: true,
          hint: Text(
            snapshot.connectionState == ConnectionState.done
                ? 'Selecciona un profesor'
                : 'Cargando profesores...',
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: nombres
              .map(
                (nombre) => DropdownMenuItem<String>(
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
