import 'package:flutter/material.dart';
import 'package:soga/widgets/selectorColores.dart';
import 'package:soga/widgets/selector_fecha.dart';
import 'package:soga/widgets/selector_hora.dart';
import 'package:soga/widgets/selector_materia.dart';
import 'package:soga/widgets/selector_prioridad.dart';

class FormularioNuevaTarea extends StatefulWidget {
  const FormularioNuevaTarea({super.key});

  @override
  State<StatefulWidget> createState() => _FormularioNuevaTarea();
}

class _FormularioNuevaTarea extends State<FormularioNuevaTarea> {
  String prioridadSeleccionada = 'Media';
  String? materiaSeleccionada;
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Title(
                    color: Colors.black,
                    child: Text(
                      "Nueva tarea",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    color: Color(0xFF7043FF),
                    style: IconButton.styleFrom(
                      backgroundColor: Color.fromARGB(100, 214, 202, 252),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Text("Titulo", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                decoration: InputDecoration(
                  hintText: "¿Qué necesitas hacer?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Text("Materia", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectorMateria(
                materiaSeleccionada: materiaSeleccionada,
                onSeleccionar: (materia) {
                  setState(() {
                    materiaSeleccionada = materia;
                  });
                },
              ),

              SizedBox(height: 10),

              Text("Prioridad", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectorPrioridad(
                prioridadSeleccionada: prioridadSeleccionada,
                onSeleccionar: (prioridad) {
                  setState(() {
                    prioridadSeleccionada = prioridad;
                  });
                },
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fecha",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectorFecha(
                          fechaSeleccionada: fechaSeleccionada,
                          onSeleccionar: (fecha) {
                            setState(() {
                              fechaSeleccionada = fecha;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hora",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectorHora(
                          horaSeleccionada: horaSeleccionada,
                          onSeleccionar: (hora) {
                            setState(() {
                              horaSeleccionada = hora;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),

              SelectorColores(),
              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 202, 252),
                  ),
                  onPressed: () {},
                  child: Text("Crear tarea"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
