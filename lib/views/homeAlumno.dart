import 'package:flutter/material.dart';
import 'package:soga/views/pantalla_tareas.dart';
import 'package:soga/widgets/formulario_nueva_tarea.dart';

import '../controllers/tarea_controller.dart';
import '../widgets/tarjeta_acceso.dart';
import '../widgets/tarjeta_tarea.dart';

class HomeAlumno extends StatefulWidget {
  const HomeAlumno({super.key});

  @override
  State<HomeAlumno> createState() => _HomeAlumnoState();
}

class _HomeAlumnoState extends State<HomeAlumno> {
  // CONTROLADOR DE TAREAS
  final TareasController controlador = TareasController();
  void abrirPantallaTareas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaTareas()),
    );
  }
  void mostrarFormularioTarea() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const FormularioNuevaTarea();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F7FC),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO MORADO
            Container(
              height: 250,
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),

              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Viernes, 16 de Octubre",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Hola, Oswaldo",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Tienes ${controlador.pendientes} tareas pendientes",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),

                    SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Progreso", style: TextStyle(color: Colors.white)),

                        Text(
                          "${controlador.completadas}/${controlador.tareas.length} completadas",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: controlador.progreso,
                        minHeight: 8,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // TÍTULO ACCESOS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "ACCESOS",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 15),

            // PRIMERA FILA DE TARJETAS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TarjetaAcceso(
                      titulo: "Tareas",
                      subtitulo: "${controlador.pendientes} pendientes",
                      icono: Icons.check_box_outlined,
                      colorFondo: Color(0xFFECE9FF),
                      colorIcono: Colors.deepPurple,
                      onTap: () {
                        abrirPantallaTareas();
                      },
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: TarjetaAcceso(
                      titulo: "Notas",
                      subtitulo: "Tus apuntes",
                      icono: Icons.description_outlined,
                      colorFondo: Color(0xFFFFEBE5),
                      colorIcono: Color(0xFFFF784F),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Falta conectar la pantalla Notas"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // SEGUNDA FILA DE TARJETAS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TarjetaAcceso(
                      titulo: "Calendario",
                      subtitulo: "Ver fechas",
                      icono: Icons.calendar_month,
                      colorFondo: Color(0xFFD5F8E9),
                      colorIcono: Color(0xFF25C99B),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Falta conectar la pantalla Calendario",
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: TarjetaAcceso(
                      titulo: "Nueva tarea",
                      subtitulo: "Agregar rápido",
                      icono: Icons.add,
                      colorFondo: Color(0xFFFFF8C4),
                      colorIcono: Color(0xFFFFB900),
                      onTap: () {
                        mostrarFormularioTarea(); 
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            SizedBox(height: 10),

            // LISTA DE TAREAS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (controlador.tareasVisibles.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        controlador.mostrarTodas
                            ? "No hay tareas registradas"
                            : "No tienes tareas pendientes",
                      ),
                    ),

                  for (final tarea in controlador.tareasVisibles)
                    TarjetaTarea(
                      tarea: tarea,

                      onCambiarEstado: () {
                        setState(() {
                          controlador.cambiarEstado(tarea);
                        });
                      },

                      onEliminar: () {
                        setState(() {
                          controlador.eliminarTarea(tarea);
                        });
                      },
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
 
