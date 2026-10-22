
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:soga/controllers/calendario_controller.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  // Controlador del calendario
  final CalendarioController controller = CalendarioController();

  // Tareas agrupadas por fecha
  late final Map<DateTime, List<String>> tareasCalendario;

  // Formato del calendario
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Fechas seleccionadas y enfocadas
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Obtener las tareas del controlador
    tareasCalendario = controller.obtenerTareasCalendario();
  }

  // Obtener las tareas correspondientes a un día
  List<String> obtenerTareas(DateTime dia) {
    DateTime fecha = DateTime(
      dia.year,
      dia.month,
      dia.day,
    );

    return tareasCalendario[fecha] ?? [];
  }

  @override
  Widget build(BuildContext context) {

    // Tareas del día seleccionado
    List<String> tareasDelDia = obtenerTareas(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Actividades'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [

          // CALENDARIO
          TableCalendar<String>(
            locale: 'es_MX',

            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,

            startingDayOfWeek: StartingDayOfWeek.monday,

            // Día seleccionado
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },

            // Cuando el usuario selecciona un día
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },

            // Obtener tareas y marcar fechas
            eventLoader: obtenerTareas,

            // Formato del calendario
            calendarFormat: _calendarFormat,

            availableCalendarFormats: const {
              CalendarFormat.month: 'Mes',
              CalendarFormat.twoWeeks: '2 semanas',
              CalendarFormat.week: 'Semana',
            },

            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },

            // Cambiar de mes
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            // Estilos
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),

              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),

              markerDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),

              outsideDaysVisible: false,
            ),

            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 20),

          // FECHA SELECCIONADA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tareas del ${DateFormat('d MMM', 'es_MX').format(_selectedDay)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // LISTA DE TAREAS
          Expanded(
            child: tareasDelDia.isEmpty
                ? const Center(
                    child: Text(
                      'No hay tareas pendientes para este día',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: tareasDelDia.length,

                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),

                        child: ListTile(
                          leading: const Icon(
                            Icons.assignment,
                            color: Colors.blueAccent,
                          ),

                          title: Text(
                            tareasDelDia[index],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
