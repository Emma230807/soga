import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:soga/datasourses/datos_temporales.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const Color _morado = Color(0xFF7043FF);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late Future<List<Map<String, dynamic>>> _consultaTareas;

  @override
  void initState() {
    super.initState();
    _actualizarConsulta();
  }

  void _actualizarConsulta() {
    _consultaTareas = DatosTemporales.obtenerTareasSupabase();
  }

  void _recargar() {
    setState(_actualizarConsulta);
  }

  DateTime? _fechaTarea(Map<String, dynamic> tarea) {
    final valor = tarea['fecha'];
    if (valor is DateTime) {
      return DateTime(valor.year, valor.month, valor.day);
    }
    if (valor is String) {
      final fecha = DateTime.tryParse(valor);
      if (fecha != null) {
        return DateTime(fecha.year, fecha.month, fecha.day);
      }
    }
    return null;
  }

  Color _colorTarea(Object? valor) {
    final nombre = (valor ?? '').toString().trim().toLowerCase();
    switch (nombre) {
      case 'morado':
      case 'violeta':
      case 'purple':
        return const Color(0xFF7043FF);
      case 'azul':
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'verde':
      case 'green':
        return const Color(0xFF25B98B);
      case 'rojo':
      case 'red':
        return const Color(0xFFEF5350);
      case 'naranja':
      case 'orange':
        return const Color(0xFFFF9B45);
      case 'amarillo':
      case 'yellow':
        return const Color(0xFFE0AF20);
      case 'rosa':
      case 'pink':
        return const Color(0xFFEC69AE);
      default:
        if (nombre.startsWith('#')) {
          final hexadecimal = nombre.substring(1);
          final numero = int.tryParse(hexadecimal, radix: 16);
          if (numero != null && hexadecimal.length == 6) {
            return Color(0xFF000000 | numero);
          }
        }
        return _morado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: _morado,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Calendario de actividades'),
        actions: [
          IconButton(
            tooltip: 'Actualizar tareas',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _consultaTareas,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: _morado),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudieron cargar las tareas: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _recargar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // El calendario conserva el comportamiento original: marca
          // y muestra solamente las tareas pendientes del alumno.
          final eventos = <DateTime, List<Map<String, dynamic>>>{};
          for (final tarea in snapshot.data ?? <Map<String, dynamic>>[]) {
            if (tarea['completada'] == true) continue;
            final dia = _fechaTarea(tarea);
            if (dia == null) continue;
            eventos.putIfAbsent(dia, () => []).add(tarea);
          }

          List<Map<String, dynamic>> tareasDe(DateTime dia) =>
              eventos[DateTime(dia.year, dia.month, dia.day)] ??
              <Map<String, dynamic>>[];

          final tareasDelDia = tareasDe(_selectedDay);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'S O G A',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Organiza tus actividades',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Consulta tus entregas y tareas pendientes',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TableCalendar<Map<String, dynamic>>(
                      locale: 'es_MX',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: tareasDe,
                      calendarFormat: _calendarFormat,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mes',
                        CalendarFormat.twoWeeks: '2 semanas',
                        CalendarFormat.week: 'Semana',
                      },
                      onFormatChanged: (format) {
                        setState(() => _calendarFormat = format);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Color(0xFFA16BFF),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: _morado,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Color(0xFFFFB900),
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: false,
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tareas del ${DateFormat('d MMMM', 'es_MX').format(_selectedDay)}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: tareasDelDia.isEmpty
                    ? const Center(
                        child: Text('No hay tareas pendientes para este día'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: tareasDelDia.length,
                        itemBuilder: (context, index) {
                          final tarea = tareasDelDia[index];
                          final color = _colorTarea(tarea['color']);
                          final titulo = (tarea['titulo'] ?? 'Sin título')
                              .toString();
                          final descripcion = (tarea['descripcion'] ?? '')
                              .toString()
                              .trim();
                          final prioridad = (tarea['prioridad'] ?? 'MEDIA')
                              .toString();
                          return Card(
                            elevation: 0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titulo,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (descripcion.isNotEmpty) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            descripcion,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          'Prioridad: ${prioridad.toLowerCase()}',
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.assignment_outlined,
                                    color: _morado,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
