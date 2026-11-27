import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/tarea.dart';

/// Tareas del alumno autenticado, consultadas exclusivamente en Supabase.
class TareasController {
  final String? matricula;
  TareasController({this.matricula});

  bool mostrarTodas = false;
  List<Tarea> _tareas = [];

  List<Tarea> get tareas => List.unmodifiable(_tareas);
  int get completadas => _tareas.where((t) => t.completada).length;
  int get pendientes => _tareas.length - completadas;
  double get progreso => _tareas.isEmpty ? 0 : completadas / _tareas.length;
  List<Tarea> get tareasVisibles =>
      mostrarTodas ? tareas : _tareas.where((t) => !t.completada).toList();

  /// Llamar al abrir la pantalla y después de guardar, editar o eliminar.
  Future<List<Tarea>> cargarTareas() async {
    final filas = await DatosTemporales.obtenerTareasSupabase();
    _tareas =
        filas
            .where(
              (fila) => matricula == null || fila['matricula'] == matricula,
            )
            .map(_desdeSupabase)
            .toList()
          ..sort((a, b) => a.fecha.compareTo(b.fecha));
    return tareas;
  }

  Future<void> cambiarEstado(Tarea tarea) async {
    await DatosTemporales.cambiarEstadoTareaSupabase(
      tarea.idTarea,
      !tarea.completada,
    );
    await cargarTareas();
  }

  Future<void> eliminarTarea(Tarea tarea) async {
    await DatosTemporales.eliminarTareaSupabase(tarea.idTarea);
    await cargarTareas();
  }

  void cambiarVista() => mostrarTodas = !mostrarTodas;

  List<Tarea> filtrarTareas(String texto, int filtro) {
    final busqueda = texto.trim().toLowerCase();
    return _tareas.where((t) {
      final coincideEstado = filtro == 0 ? !t.completada : t.completada;
      return coincideEstado && t.titulo.toLowerCase().contains(busqueda);
    }).toList();
  }

  static Tarea _desdeSupabase(Map<String, dynamic> fila) {
    final fecha = DateTime.parse(fila['fecha'].toString());
    final prioridadSql = (fila['prioridad'] ?? 'MEDIA')
        .toString()
        .toLowerCase();
    final prioridad = prioridadSql.isEmpty
        ? 'Media'
        : '${prioridadSql[0].toUpperCase()}${prioridadSql.substring(1)}';

    return Tarea(
      idTarea: (fila['idTarea'] as num).toInt(),
      titulo: (fila['titulo'] ?? '').toString(),
      descripcion: (fila['descripcion'] ?? '').toString(),
      prioridad: prioridad,
      fecha: fecha,
      idMateria: (fila['idMateria'] as num?)?.toInt() ?? 0,
      color: (fila['color'] ?? 'Morado').toString(),
      matricula: (fila['matricula'] ?? '').toString(),
      alumno: '',
      fechaEntrega: '${fecha.day}/${fecha.month}/${fecha.year}',
      completada: fila['completada'] == true,
    );
  }
}
