import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/tarea.dart';
import 'package:soga/views/detalle_pantalla.dart';
import 'package:soga/widgets/tarjeta_tarea.dart';

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({super.key});

  @override
  State<PantallaTareas> createState() => _PantallaTarea();
}

class _PantallaTarea extends State<PantallaTareas> {
  int filtroSeleccionado = 0;
  String textoBusqueda = '';
  late Future<List<Tarea>> _consultaTareas;
  final Set<int> _operacionesEnCurso = {};

  @override
  void initState() {
    super.initState();
    _recargarTareas();
  }

  void _recargarTareas() {
    _consultaTareas = _obtenerTareas();
  }

  Future<List<Tarea>> _obtenerTareas() async {
    final registros = await DatosTemporales.obtenerTareasSupabase();
    return registros.map(_convertirTarea).toList();
  }

  Tarea _convertirTarea(Map<String, dynamic> registro) {
    final fecha = DateTime.parse(registro['fecha'] as String);
    final prioridad = (registro['prioridad'] as String? ?? 'MEDIA')
        .toLowerCase();
    final prioridadVisible = prioridad.isEmpty
        ? 'Media'
        : '${prioridad[0].toUpperCase()}${prioridad.substring(1)}';

    return Tarea(
      idTarea: (registro['idTarea'] as num).toInt(),
      titulo: registro['titulo'] as String? ?? 'Sin título',
      descripcion: registro['descripcion'] as String? ?? '',
      prioridad: prioridadVisible,
      fecha: fecha,
      idMateria: (registro['idMateria'] as num?)?.toInt() ?? 0,
      color: registro['color'] as String? ?? 'Morado',
      matricula: registro['matricula'] as String? ?? '',
      fechaEntrega: '${fecha.day}/${fecha.month}/${fecha.year}',
      completada: registro['completada'] as bool? ?? false,
      alumno: '',
    );
  }

  Future<void> _cambiarEstado(Tarea tarea) async {
    if (_operacionesEnCurso.contains(tarea.idTarea)) return;
    _operacionesEnCurso.add(tarea.idTarea);
    try {
      await DatosTemporales.cambiarEstadoTareaSupabase(
        tarea.idTarea,
        !tarea.completada,
      );
      if (!mounted) return;
      setState(_recargarTareas);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tarea.completada
                ? 'Tarea marcada como pendiente'
                : 'Tarea marcada como completada',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la tarea: $e')),
      );
    } finally {
      _operacionesEnCurso.remove(tarea.idTarea);
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    if (_operacionesEnCurso.contains(tarea.idTarea)) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text(
          '¿Quieres eliminar "${tarea.titulo}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    if (_operacionesEnCurso.contains(tarea.idTarea)) return;
    _operacionesEnCurso.add(tarea.idTarea);
    try {
      await DatosTemporales.eliminarTareaSupabase(tarea.idTarea);
      if (!mounted) return;
      setState(_recargarTareas);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea eliminada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la tarea: $e')),
      );
    } finally {
      _operacionesEnCurso.remove(tarea.idTarea);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FF),
      appBar: AppBar(
        title: const Text(
          'Mis tareas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepPurple,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar tareas',
            icon: const Icon(Icons.refresh, color: Colors.deepPurple),
            onPressed: () => setState(_recargarTareas),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              TextField(
                onChanged: (texto) => setState(() => textoBusqueda = texto),
                decoration: InputDecoration(
                  hintText: 'Buscar tareas...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Pendientes'),
                    selected: filtroSeleccionado == 0,
                    selectedColor: Colors.deepPurple,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: filtroSeleccionado == 0
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (_) => setState(() => filtroSeleccionado = 0),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Completadas'),
                    selected: filtroSeleccionado == 1,
                    selectedColor: Colors.deepPurple,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: filtroSeleccionado == 1
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (_) => setState(() => filtroSeleccionado = 1),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              FutureBuilder<List<Tarea>>(
                future: _consultaTareas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No fue posible consultar Supabase: ${snapshot.error}',
                        ),
                        TextButton(
                          onPressed: () => setState(_recargarTareas),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    );
                  }

                  final busqueda = textoBusqueda.trim().toLowerCase();
                  final tareasFiltradas = (snapshot.data ?? <Tarea>[]).where((
                    tarea,
                  ) {
                    final coincideEstado = filtroSeleccionado == 0
                        ? !tarea.completada
                        : tarea.completada;
                    return coincideEstado &&
                        tarea.titulo.toLowerCase().contains(busqueda);
                  }).toList();

                  if (tareasFiltradas.isEmpty) {
                    return const Text('No hay tareas para este filtro');
                  }

                  return Column(
                    children: [
                      for (final tarea in tareasFiltradas)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PantallaDetalleTarea(tarea: tarea),
                            ),
                          ),
                          child: TarjetaTarea(
                            tarea: tarea,
                            onCambiarEstado: () => _cambiarEstado(tarea),
                            onEliminar: () => _eliminarTarea(tarea),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
