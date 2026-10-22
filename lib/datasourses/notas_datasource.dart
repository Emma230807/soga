
import 'package:soga/models/nota.dart';

class NotasDataSource {

  // LISTA DONDE SE ALMACENAN LAS NOTAS
  static final List<Nota> _notas = [];

  // GENERADOR DE IDENTIFICADORES
  static int _siguienteId = 1;

  int generarId() {
    return _siguienteId++;
  }

  // AGREGAR UNA NOTA
  void agregarNota(Nota nota) {
    _notas.add(nota);
  }

  // OBTENER TODAS LAS NOTAS
  List<Nota> obtenerNotas() {
    return List.from(_notas);
  }

  // BUSCAR UNA NOTA POR ID
  Nota? buscarNota(int id) {
    for (final nota in _notas) {
      if (nota.id == id) {
        return nota;
      }
    }
    return null;
  }

  // ELIMINAR UNA NOTA
  void eliminarNota(int id) {
    _notas.removeWhere((nota) => nota.id == id);
  }

  // ACTUALIZAR UNA NOTA
  void actualizarNota(Nota notaActualizada) {
    int posicion = _notas.indexWhere(
      (nota) => nota.id == notaActualizada.id,
    );

    if (posicion != -1) {
      _notas[posicion] = notaActualizada;
    }
  }
}
