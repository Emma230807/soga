import 'package:flutter/material.dart';

class PantallaNotificaciones extends StatelessWidget {
  const PantallaNotificaciones({super.key});

  final List<Map<String, String>> notificaciones = const [
    {
      'titulo': 'Nueva tarea asignada',
      'mensaje': 'El profesor de Matemáticas ha asignado una nueva tarea.',
      'fecha': 'Hoy, 10:30 AM',
    },
    {
      'titulo': 'Calificación disponible',
      'mensaje': 'Tu calificación de Programación ya está disponible.',
      'fecha': 'Hoy, 9:15 AM',
    },
    {
      'titulo': 'Asesoría programada',
      'mensaje': 'Tienes una asesoría de Matemáticas programada.',
      'fecha': 'Ayer, 3:45 PM',
    },
    {
      'titulo': 'Recordatorio de tarea',
      'mensaje': 'La tarea de Base de Datos vence mañana.',
      'fecha': 'Ayer, 12:00 PM',
    },
    {
      'titulo': 'Aviso del docente',
      'mensaje': 'El profesor de Desarrollo Móvil publicó un aviso.',
      'fecha': '27 oct, 8:00 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      appBar: AppBar(
        backgroundColor: Colors.white,

        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepPurple,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        title: const Text(
          "Mis notificaciones",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notificaciones.length,

        itemBuilder: (context, index) {
          final notificacion = notificaciones[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.all(14),

              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE4FF),
                  borderRadius: BorderRadius.circular(12),
                ),

                // Único ícono de todas las notificaciones
                child: const Icon(
                  Icons.notifications,
                  color: Colors.deepPurple,
                  size: 26,
                ),
              ),

              title: Text(
                notificacion['titulo']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),

                  Text(notificacion['mensaje']!),

                  const SizedBox(height: 8),

                  Text(
                    notificacion['fecha']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}