import 'package:soga/datasourses/datos_temporales.dart';

class CalendarioController {
  final String? matricula;
  CalendarioController({this.matricula});

  Map<DateTime, List<String>> obtenerTareasCalendario() {
    final calendario = <DateTime, List<String>>{};
    for (final tarea in DatosTemporales.obtenerTareas(matricula: matricula)) {
      if (tarea.completada) continue;
      final fecha = DateTime(tarea.fecha.year, tarea.fecha.month, tarea.fecha.day);
      calendario.putIfAbsent(fecha, () => []).add(tarea.titulo);
    }
    return calendario;
  }
}
