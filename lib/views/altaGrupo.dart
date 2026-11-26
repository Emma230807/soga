import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/models/grupo.dart';
import 'package:soga/datasourses/grupos_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AltaGrupo extends StatefulWidget {
  const AltaGrupo({super.key});

  @override
  State<AltaGrupo> createState() => _AltaGrupoState();
}

class _AltaGrupoState extends State<AltaGrupo> {
  final TextEditingController idGrupoController = TextEditingController();
  final TextEditingController nombreGrupoController = TextEditingController();
  bool guardando = false;
  Future<void> guardarGrupo() async {
    final id = idGrupoController.text.trim();
    final nombre = nombreGrupoController.text.trim();

    if (id.isEmpty || nombre.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final grupo = Grupo(idGrupo: id, nombreGrupo: nombre);

      await GruposSupabase.registrarGrupo(grupo);

      if (!mounted) return;

      idGrupoController.clear();
      nombreGrupoController.clear();

      mostrarMensaje('Grupo registrado correctamente');
    } on PostgrestException catch (e) {
      if (!mounted) return;

      if (e.code == '23505') {
        mostrarMensaje('El ID del grupo ya existe');
      } else {
        mostrarMensaje('Error: ${e.message}');
      }
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje('Error al registrar el grupo');
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
  void dispose() {
    idGrupoController.dispose();
    nombreGrupoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FF),

      body: SingleChildScrollView(
        child: Column(
          children: [
            EncabezadoSoga(
              titulo: "Agregar grupo",
              accion: "Registrar nuevo grupo",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ENCABEZADO DEL FORMULARIO
                  const Text(
                    "Datos del grupo",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Ingresa la información para registrar un nuevo grupo.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // ID DEL GRUPO
                  const Text(
                    "ID del grupo",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: idGrupoController,
                    decoration: InputDecoration(
                      hintText: "Ej. G001",
                      prefixIcon: const Icon(
                        Icons.numbers,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // NOMBRE DEL GRUPO
                  const Text(
                    "Nombre del grupo",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: nombreGrupoController,
                    decoration: InputDecoration(
                      hintText: "Ej. Desarrollo de Software 401",
                      prefixIcon: const Icon(
                        Icons.groups,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOTÓN AGREGAR GRUPO
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: guardando ? null : guardarGrupo,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Agregar grupo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
