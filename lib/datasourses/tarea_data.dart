
import '../models/tarea.dart';

class TareasData {
  static List<Tarea> obtenerTareas() {
    return [
      const Tarea(
        titulo: "Entregar ensayo de Historia",
        fechaEntrega: "8 nov",
        instrucciones: "Ensayo sobre la revolucion francesa minimo una cuartilla",
      ),
      const Tarea(
        titulo: "Resolver ejercicios de cálculo",
        fechaEntrega: "10 nov",
        instrucciones: "Resover los ejercicios sobre derivadas"
      ),
      const Tarea(
        titulo: "Preparar presentación de Química",
        fechaEntrega: "12 nov",
        instrucciones: "Elabora una presentacion sobre los metodos de balanceo de ecuaciones "
      ),
      const Tarea(
        titulo: "Revisar apuntes de Literatura",
        fechaEntrega: "13 nov",
      ),
      const Tarea(
        titulo: "Leer capítulo 1",
        fechaEntrega: "7 nov",
        completada: true,
      ),
    ];
  }
}
