class Tarea {
  final String titulo;
  final String fechaEntrega;
  final String instrucciones;
  final bool completada;

  const Tarea({
    required this.titulo,
    required this.fechaEntrega,
    this.instrucciones="Sin Instrucciones",
    this.completada = false,
  });
}
