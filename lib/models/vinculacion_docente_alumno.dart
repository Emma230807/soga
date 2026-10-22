enum EstadoVinculacion { pendiente, aceptada, rechazada }

class VinculacionDocenteAlumno {
  final int idDocente;
  final String codigoAlumno;
  EstadoVinculacion estado;

  VinculacionDocenteAlumno({
    required this.idDocente,
    required this.codigoAlumno,
    this.estado = EstadoVinculacion.pendiente,
  });

  bool get estaAceptada {
    return estado == EstadoVinculacion.aceptada;
  }

  void aceptar() {
    estado = EstadoVinculacion.aceptada;
  }

  void rechazar() {
    estado = EstadoVinculacion.rechazada;
  }
}
