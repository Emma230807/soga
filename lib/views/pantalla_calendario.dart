import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Configuración del formato del calendario (Mes, Semana, etc.)
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Fechas seleccionadas y enfocadas
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Calendario'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          TableCalendar(
            // 1. Rango de fechas permitido en el calendario
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            
            // 2. Vincular el día seleccionado actual
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            
            // 3. Acción al presionar un día
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // Actualiza el mes enfocado si cambia
                });
              }
            },
            
            // 4. Configurar el formato del calendario (Mes, 2 semanas, semana)
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            
            // 5. Acción al cambiar de mes o página
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            // 6. Estilos visuales personalizados
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          
          // Sección inferior para mostrar el día seleccionado o eventos
          Expanded(
            child: Center(
              child: Text(
                'Día seleccionado:\n${_selectedDay?.day}/${_selectedDay?.month}/${_selectedDay?.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
