import 'package:flutter/material.dart';
import 'package:soga/datasourses/profesores_supabase.dart';

class SelectorDocente extends StatefulWidget {
  final String? docenteseleccionada;
  final ValueChanged<String?> onSeleccionar;

  const SelectorDocente({
    super.key,
    required this.docenteseleccionada,
    required this.onSeleccionar,
  });

  @override
  State<SelectorDocente> createState() => _SelectorDocenteState();
}

class _SelectorDocenteState extends State<SelectorDocente> {
  late Future<List<Map<String, dynamic>>> _consulta;

  @override
  void initState() {
    super.initState();
    _consulta = ProfesoresSupabase.obtenerProfesores();
  }

  void _recargar() => setState(() {
    _consulta = ProfesoresSupabase.obtenerProfesores();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _consulta,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Row(
            children: [
              const Expanded(child: Text('No se pudieron cargar los docentes')),
              IconButton(onPressed: _recargar, icon: const Icon(Icons.refresh)),
            ],
          );
        }
        final docentes = snapshot.data ?? [];
        final nombres =
            docentes
                .map((d) => (d['nombre'] ?? '').toString().trim())
                .where((nombre) => nombre.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final elegido = nombres.contains(widget.docenteseleccionada)
            ? widget.docenteseleccionada
            : null;
        return DropdownButtonFormField<String>(
          key: ValueKey('${widget.docenteseleccionada}:${nombres.join('|')}'),
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
