import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/nota.dart';

/// Controlador de notas persistidas en Supabase para el alumno autenticado.
class NotasController {
  /// Devuelve false cuando la entrada no es válida. Un error de Supabase
  /// se propaga para que la pantalla pueda mostrarlo.
  Future<bool> guardarNota(String titulo, String contenido, Color color) async {
    if (titulo.trim().isEmpty || contenido.trim().isEmpty) return false;
    await DatosTemporales.guardarNotaSupabase(
      titulo: titulo,
      contenido: contenido,
      color: color,
    );
    return true;
  }

  Future<List<Nota>> obtenerNotas() async {
    final filas = await DatosTemporales.obtenerNotasSupabase();
    return filas.map((fila) {
      final fecha =
          DateTime.tryParse((fila['fechaCreacion'] ?? '').toString()) ??
          DateTime.now();
      return Nota(
        id: (fila['idNota'] as num).toInt(),
        titulo: (fila['titulo'] ?? '').toString(),
        contenido: (fila['contenido'] ?? '').toString(),
        color: _colorDesdeSupabase(fila['color']),
        fechaCreacion: fecha,
      );
    }).toList();
  }

  Future<void> actualizarNota({
    required int idNota,
    required String titulo,
    required String contenido,
    required Color color,
  }) => DatosTemporales.actualizarNotaSupabase(
    idNota: idNota,
    titulo: titulo,
    contenido: contenido,
    color: color,
  );

  Future<void> eliminarNota(int idNota) =>
      DatosTemporales.eliminarNotaSupabase(idNota);

  static Color _colorDesdeSupabase(dynamic valor) {
    final texto = (valor ?? '').toString().replaceFirst('#', '');
    final numero = int.tryParse(texto, radix: 16);
    if (numero == null) return const Color(0xFFFFF4B8);
    if (texto.length == 6) return Color(0xFF000000 | numero);
    if (texto.length == 8) return Color(numero);
    return const Color(0xFFFFF4B8);
  }
}
