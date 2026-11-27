import 'package:soga/datasourses/datos_temporales.dart';

/// Calendario de tareas pendientes del alumno autenticado.
class CalendarioController {
  final String? matricula;

  CalendarioController({this.matricula});

  /// Es asíncrono porque consulta Supabase y no los datos de prueba.
  Future<Map<DateTime, List<String>>> obtenerTareasCalendario() async {
    final filas = await DatosTemporales.obtenerTareasSupabase();
    final calendario = <DateTime, List<String>>{};

    for (final fila in filas) {
      if (matricula != null && fila['matricula'] != matricula) continue;
      if (fila['completada'] == true) continue;

      final fechaTexto = fila['fecha']?.toString();
      if (fechaTexto == null) continue;
      final fechaOriginal = DateTime.tryParse(fechaTexto);
      if (fechaOriginal == null) continue;
      final fecha = DateTime(
        fechaOriginal.year,
        fechaOriginal.month,
        fechaOriginal.day,
      );
      final titulo = (fila['titulo'] ?? '').toString().trim();
      if (titulo.isEmpty) continue;
      calendario.putIfAbsent(fecha, () => <String>[]).add(titulo);
    }
    return calendario;
  }
}
