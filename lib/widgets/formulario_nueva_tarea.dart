import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/selectorColores.dart';
import 'package:soga/widgets/selector_fecha.dart';
import 'package:soga/widgets/selector_materia.dart';
import 'package:soga/widgets/selector_prioridad.dart';

class FormularioNuevaTarea extends StatefulWidget {
  const FormularioNuevaTarea({super.key});

  @override
  State<StatefulWidget> createState() => _FormularioNuevaTarea();
}

class _FormularioNuevaTarea extends State<FormularioNuevaTarea> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  bool guardando = false;
  String prioridadSeleccionada = 'Media';
  String? materiaSeleccionada;
  DateTime? fechaSeleccionada;
  Color colorSelec = Colors.purple;

  Future<void> crearTarea() async {
    if (guardando) return;

    final titulo = tituloController.text.trim();
    final materia = materiaSeleccionada?.trim();
    final fecha = fechaSeleccionada;

    if (titulo.isEmpty || materia == null || materia.isEmpty || fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título, materia y fecha')),
      );
      return;
    }

    setState(() => guardando = true);
    try {
      final idMateria = await DatosTemporales.obtenerIdMateriaSupabase(materia);
      if (idMateria == null) {
        throw Exception('La materia "$materia" no está registrada en Supabase');
      }

      final colores = <Color, String>{
        Colors.purple: 'Morado',
        Colors.red: 'Rojo',
        Colors.blue: 'Azul',
        Colors.green: 'Verde',
        Colors.orange: 'Naranja',
        Colors.yellow: 'Amarillo',
      };

      await DatosTemporales.guardarTareaSupabase(
        titulo: titulo,
        descripcion: descripcionController.text.trim(),
        prioridad: prioridadSeleccionada,
        fecha: fecha,
        idMateria: idMateria,
        color: colores[colorSelec] ?? 'Morado',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea creada correctamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la tarea: $e')),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

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
                controller: tituloController,
                decoration: InputDecoration(
                  hintText: "¿Qué necesitas hacer?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: descripcionController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Describe lo que necesitas hacer",
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

              Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectorFecha(
                fechaSeleccionada: fechaSeleccionada,
                onSeleccionar: (fecha) {
                  setState(() {
                    fechaSeleccionada = fecha;
                  });
                },
              ),

              SizedBox(height: 10),

              Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),

              SelectorColores(
                colorSeleccionado: colorSelec,
                onSeleccionar: (color) {
                  setState(() {
                    colorSelec = color;
                  });
                },
              ),
              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 202, 252),
                  ),
                  onPressed: guardando ? null : crearTarea,
                  child: Text(guardando ? 'Guardando...' : 'Crear tarea'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
