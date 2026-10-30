import 'package:flutter/material.dart';
import 'package:soga/controllers/tarea_controller.dart';
import 'package:soga/views/detalle_pantalla.dart';
import 'package:soga/widgets/tarjeta_tarea.dart';

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({super.key});

  @override
  State<PantallaTareas> createState() => _PantallaTarea();
}

class _PantallaTarea extends State<PantallaTareas> {
  int filtroSeleccionado = 0;
  String textoBusqueda = "";

  final TareasController controlador = TareasController();

  @override
  Widget build(BuildContext context) {
    // OBTENER LAS TAREAS FILTRADAS DEL CONTROLADOR
    final tareasFiltradas = controlador.filtrarTareas(
      textoBusqueda,
      filtroSeleccionado,
    );

    return Scaffold(
      backgroundColor: Color(0xFFFCF7FF),

      appBar: AppBar(
        title: Text(
          "Mis tareas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,

        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepPurple,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),

              // BUSCADOR
              TextField(
                onChanged: (texto) {
                  setState(() {
                    textoBusqueda = texto;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Buscar tareas...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 15),

              // BOTONES DE FILTRO
              Row(
                children: [
                  ChoiceChip(
                    label: Text("Pendientes"),
                    selected: filtroSeleccionado == 0,
                    selectedColor: Colors.deepPurple,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: filtroSeleccionado == 0
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (valor) {
                      setState(() {
                        filtroSeleccionado = 0;
                      });
                    },
                  ),

                  SizedBox(width: 10),

                  ChoiceChip(
                    label: Text("Completadas"),
                    selected: filtroSeleccionado == 1,
                    selectedColor: Colors.deepPurple,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: filtroSeleccionado == 1
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (valor) {
                      setState(() {
                        filtroSeleccionado = 1;
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 15),

              // LISTA DE TAREAS
              if (tareasFiltradas.isEmpty)
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    textoBusqueda.isNotEmpty
                        ? "No se encontraron tareas"
                        : filtroSeleccionado == 0
                        ? "No tienes tareas pendientes"
                        : "No tienes tareas completadas",
                  ),
                ),

              for (final tarea in controlador.tareasVisibles)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PantallaDetalleTarea(tarea: tarea),
                      ),
                    );
                  },

                  child: TarjetaTarea(
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
