import '../models/tarea.dart';
import '../datasourses/datos_temporales.dart';

class TareasController {
  final String? matricula;
  Stream<List<Tarea>> observarTareasFirebase() => DatosTemporales.observarTareasUsuarioFirebase();
  Future<void> cambiarEstadoFirebase(Tarea tarea) => DatosTemporales.actualizarEstadoTareaFirebase(tarea);
  Future<void> eliminarFirebase(Tarea tarea) => DatosTemporales.borrarTareaFirebase(tarea);
  TareasController({this.matricula});

  // Consulta en cada acceso: no conserva una copia obsoleta.
  List<Tarea> get tareas => DatosTemporales.obtenerTareas(matricula: matricula);
  bool mostrarTodas = false;
  int get completadas => tareas.where((t) => t.completada).length;
  int get pendientes => tareas.length - completadas;
  double get progreso => tareas.isEmpty ? 0 : completadas / tareas.length;
  List<Tarea> get tareasVisibles => mostrarTodas
      ? tareas : tareas.where((t) => !t.completada).toList();
  void cambiarEstado(Tarea tarea) => DatosTemporales.cambiarEstadoTarea(tarea.idTarea);
  void eliminarTarea(Tarea tarea) => DatosTemporales.eliminarTarea(tarea.idTarea);
  void cambiarVista() => mostrarTodas = !mostrarTodas;
  List<Tarea> filtrarTareas(String texto, int filtro) => tareas.where((t) {
    final coincideEstado = filtro == 0 ? !t.completada : t.completada;
    return coincideEstado && t.titulo.toLowerCase().contains(texto.trim().toLowerCase());
  }).toList();
}
