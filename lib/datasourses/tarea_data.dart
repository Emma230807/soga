import '../models/tarea.dart';

class TareasData {
  static List<Tarea> obtenerTareas() {
    return [
      Tarea(
        idTarea: 1,
        titulo: "Entregar ensayo de Historia",
        descripcion: "Redactar y entregar un ensayo de Historia",
        prioridad: "Alta",
        fecha: DateTime(2026, 11, 8),
        idMateria: 3,
        color: "Morado",
        matricula: "ALU-0002",
        alumno: "Ana Martínez",
        fechaEntrega: "8 nov",
        instrucciones: "Ensayo sobre la revolucion francesa minimo una cuartilla",
      ),
      Tarea(
        idTarea: 2,
        titulo: "Resolver ejercicios de cálculo",
        descripcion: "Resolver los ejercicios de cálculo",
        prioridad: "Alta",
        fecha: DateTime(2026, 11, 10),
        idMateria: 1,
        color: "Morado",
        matricula: "ALU-0002",
        alumno: "Ana Martínez",
        fechaEntrega: "10 nov",
        instrucciones: "Resover los ejercicios sobre derivadas"
      ),
      Tarea(
        idTarea: 3,
        titulo: "Preparar presentación de Química",
        descripcion: "Preparar una presentación sobre Química",
        prioridad: "Media",
        fecha: DateTime(2026, 11, 12),
        idMateria: 4,
        color: "Verde",
        matricula: "ALU-0002",
        alumno: "Ana Martínez",
        fechaEntrega: "12 nov",
        instrucciones: "Elabora una presentacion sobre los metodos de balanceo de ecuaciones "
      ),
      Tarea(
        idTarea: 4,
        titulo: "Revisar apuntes de Literatura",
        descripcion: "Repasar los apuntes de Literatura",
        prioridad: "Baja",
        fecha: DateTime(2026, 11, 13),
        idMateria: 5,
        color: "Azul",
        matricula: "ALU-0002",
        alumno: "Ana Martínez",
        fechaEntrega: "13 nov",
      ),
      Tarea(
        idTarea: 5,
        titulo: "Leer capítulo 1",
        descripcion: "Leer el primer capítulo del libro",
        prioridad: "Media",
        fecha: DateTime(2026, 11, 7),
        idMateria: 3,
        color: "Morado",
        matricula: "ALU-0002",
        alumno: "Ana Martínez",
        fechaEntrega: "7 nov",
        completada: true,
      ),
    ];
  }
}
