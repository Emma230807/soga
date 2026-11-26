import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/datasourses/materias_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaAgregarMateria extends StatefulWidget {
  const PantallaAgregarMateria({super.key});
  @override
  State<PantallaAgregarMateria> createState() => _PantallaAgregarMateriaState();
}

class _PantallaAgregarMateriaState extends State<PantallaAgregarMateria> {
  final nombreMateriaController = TextEditingController();

  bool guardando = false;

  @override
  void dispose() {
    nombreMateriaController.dispose();
    super.dispose();
  }

  Future<void> guardarMateria() async {
    final nombre = nombreMateriaController.text.trim();

    if (nombre.isEmpty) {
      mostrarMensaje('Ingresa el nombre de la materia');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await MateriasSupabase.registrarMateria(nombre);

      if (!mounted) return;

      nombreMateriaController.clear();
      mostrarMensaje('Materia registrada correctamente');
    } on PostgrestException catch (e) {
      if (!mounted) return;
      mostrarMensaje('Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje('Error al registrar la materia');
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
    
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoSoga(
              titulo: "Agregar materia",
              accion: "Registra una nueva materia",
            ),

            // CUERPO DEL FORMULARIO
            Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la materia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOMBRE
                        const Text(
                          'Nombre de la materia',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: nombreMateriaController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Matematicas',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BOTÓN GUARDAR - SIN FUNCIONALIDAD
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton.icon(
                      onPressed: guardando ? null : guardarMateria,

                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar materia'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7140FF),
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
