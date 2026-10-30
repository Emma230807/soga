class Tarea {
  int idTarea;
  String descripcion;
  String prioridad;
  DateTime fecha;
  int idMateria;
  String titulo;
  String color;
  String matricula;
  String fechaEntrega;
  bool completada;
  final String instrucciones;
  String alumno;

  Tarea({
    required this.idTarea,
    required this.descripcion,
    required this.prioridad,
    required this.fecha,
    required this.idMateria,
    required this.titulo,
    required this.color,
    required this.matricula,
    required this.fechaEntrega,
    this.instrucciones = "Sin Instrucciones",
    this.completada = false,
    required this.alumno,
  });
}
