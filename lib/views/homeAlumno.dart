
import 'package:flutter/material.dart';

class HomeAlumno extends StatefulWidget {
  const HomeAlumno({super.key});

  @override
  State<HomeAlumno> createState() => _HomeAlumnoState();
}

class _HomeAlumnoState extends State<HomeAlumno> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ENCABEZADO MORADO
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF693BFF),
                    Color(0xFF9B66F5),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),

                      const Text(
                        'Jueves, 17 de septiembre',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        '¡Hola, Oswaldo! 👋',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Tienes 4 tareas pendientes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '1/5 completadas',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.2,
                          minHeight: 7,
                          backgroundColor: Colors.white30,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD76A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // CONTENIDO PRINCIPAL
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACCESOS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PRIMERA FILA DE TARJETAS
                  Row(
                    children: [
                      tarjeta(
                        'Tareas',
                        '4 pendientes',
                        Icons.check_circle_outline,
                        const Color(0xFFECE9FF),
                        const Color(0xFF7454EE),
                      ),

                      const SizedBox(width: 12),

                      tarjeta(
                        'Notas',
                        'Tus apuntes',
                        Icons.description_outlined,
                        const Color(0xFFFFEBE5),
                        const Color(0xFFFF784F),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // SEGUNDA FILA DE TARJETAS
                  Row(
                    children: [
                      tarjeta(
                        'Calendario',
                        'Ver fechas',
                        Icons.calendar_month,
                        const Color(0xFFD5F8E9),
                        const Color(0xFF25C99B),
                      ),

                      const SizedBox(width: 12),

                      tarjeta(
                        'Nueva tarea',
                        'Agregar rápido',
                        Icons.add,
                        const Color(0xFFFFF8C4),
                        const Color(0xFFFFB900),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ENCABEZADO DE PENDIENTES
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PENDIENTES',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ver todas →',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7454EE),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // LISTA VISUAL DE TAREAS
                  tarea(
                    'Entregar ensayo de Historia',
                    'Historia Universal',
                    '8 nov',
                    Colors.deepPurple,
                  ),

                  tarea(
                    'Resolver ejercicios de cálculo',
                    'Matemáticas',
                    '10 nov',
                    Colors.deepOrange,
                  ),

                  tarea(
                    'Preparar presentación de Química',
                    'Química',
                    '12 nov',
                    Colors.amber,
                  ),

                  tarea(
                    'Revisar apuntes de Literatura',
                    'Literatura',
                    '13 nov',
                    Colors.deepPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DISEÑO DE UNA TARJETA
  Widget tarjeta(
    String titulo,
    String subtitulo,
    IconData icono,
    Color fondo,
    Color colorIcono,
  ) {
    return Expanded(
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorIcono,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DISEÑO DE UNA TAREA PENDIENTE
  Widget tarea(
    String titulo,
    String materia,
    String fecha,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            color: color,
            size: 23,
          ),

          const SizedBox(width: 10),

          Container(
            width: 3,
            height: 35,
            color: color,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  materia,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            fecha,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
