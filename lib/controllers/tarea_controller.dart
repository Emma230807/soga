import '../models/tarea.dart';
import '../datasourses/tarea_data.dart';

class TareasController {
  List<Tarea> tareas = TareasData.obtenerTareas();

  bool mostrarTodas = false;

  // CONTAR TAREAS COMPLETADAS
  int get completadas {
    return tareas.where((tarea) => tarea.completada).length;
  }

  // CONTAR TAREAS PENDIENTES
  int get pendientes {
    return tareas.length - completadas;
  }

  // CALCULAR PROGRESO
  double get progreso {
    if (tareas.isEmpty) {
      return 0.0;
    }

    return completadas / tareas.length;
  }

  // OBTENER LAS TAREAS VISIBLES
  List<Tarea> get tareasVisibles {
    if (mostrarTodas) {
      return tareas;
    }

    return tareas.where((tarea) => !tarea.completada).toList();
  }

  // CAMBIAR ESTADO DE UNA TAREA
  void cambiarEstado(Tarea tarea) {
    int indice = tareas.indexOf(tarea);

    if (indice != -1) {
      tareas[indice].completada = !tarea.completada;
    }
  }

  // ELIMINAR UNA TAREA
  void eliminarTarea(Tarea tarea) {
    tareas.remove(tarea);
  }

  // MOSTRAR TODAS O SOLO PENDIENTES
  void cambiarVista() {
    mostrarTodas = !mostrarTodas;
  }

  List<Tarea> filtrarTareas(String texto, int filtro) {
    return tareas.where((tarea) {
      bool coincideFiltro = filtro == 0 ? !tarea.completada : tarea.completada;

      bool coincideBusqueda = tarea.titulo.toLowerCase().contains(
        texto.toLowerCase().trim(),
      );

      return coincideFiltro && coincideBusqueda;
    }).toList();
  }
}
