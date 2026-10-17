class Tarea {
  final String titulo;
  final String fechaEntrega;
  final bool completada;

  const Tarea({
    required this.titulo,
    required this.fechaEntrega,
    this.completada = false,
  });
}
