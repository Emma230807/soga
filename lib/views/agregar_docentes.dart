import 'package:flutter/material.dart';

import 'package:soga/datasourses/profesores_supabase.dart';
import 'package:soga/widgets/lista_admin_registros.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaAgregarDocente extends StatefulWidget {
  const PantallaAgregarDocente({super.key});

  @override
  State<PantallaAgregarDocente> createState() => _PantallaAgregarDocenteState();
}

class _PantallaAgregarDocenteState extends State<PantallaAgregarDocente> {
  final numeroEmpleadoController = TextEditingController();
  final nombreController = TextEditingController();
  final usuarioController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool guardando = false;
  int _versionLista = 0;

  @override
  void dispose() {
    numeroEmpleadoController.dispose();
    nombreController.dispose();
    usuarioController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> guardarProfesor() async {
    final numeroEmpleado = numeroEmpleadoController.text.trim();
    final nombre = nombreController.text.trim();
    final usuario = usuarioController.text.trim();
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text;

    if (numeroEmpleado.isEmpty ||
        nombre.isEmpty ||
        usuario.isEmpty ||
        correo.isEmpty ||
        contrasena.trim().isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    if (contrasena.length < 8) {
      mostrarMensaje('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await ProfesoresSupabase.registrarProfesor(
        numeroEmpleado: numeroEmpleado,
        nombre: nombre,
        usuario: usuario,
        correo: correo,
        contrasena: contrasena,
      );

      if (!mounted) return;

      numeroEmpleadoController.clear();
      nombreController.clear();
      usuarioController.clear();
      correoController.clear();
      contrasenaController.clear();

      mostrarMensaje('Profesor registrado correctamente');
      setState(() => _versionLista++);
    } on FunctionException catch (e) {
      debugPrint('Código: ${e.status}');
      debugPrint('Detalles: ${e.details}');
      if (!mounted) return;

      final detalles = e.details;

      mostrarMensaje(
        detalles is Map
            ? '${detalles['mensaje'] ?? detalles['message'] ?? 'Error al registrar'}'
            : 'Error al registrar: ${e.status}',
      );
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje('Error al registrar el profesor');
      debugPrint('Error general: $e');
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 25,
                ),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'PANEL ADMINISTRADOR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Agregar docente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registra un nuevo docente en el sistema.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // FORMULARIO
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del docente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                          _campo(
                            'Número de empleado',
                            'Ingresa el número de empleado',
                            Icons.badge_outlined,
                            controller: numeroEmpleadoController,
                          ),

                          const SizedBox(height: 20),

                          _campo(
                            'Nombre completo',
                            'Ej. María López',
                            Icons.person_outline,
                            controller: nombreController,
                          ),

                          const SizedBox(height: 20),

                          _campo(
                            'Usuario',
                            'Ej. MariaL',
                            Icons.account_circle_outlined,
                            controller: usuarioController,
                          ),

                          const SizedBox(height: 20),

                          _campo(
                            'Correo electrónico',
                            'docente@correo.com',
                            Icons.email_outlined,
                            controller: correoController,
                            tipo: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 20),

                          _campo(
                            'Contraseña',
                            'Ingresa la contraseña',
                            Icons.lock_outline,
                            controller: contrasenaController,
                            ocultar: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: guardando ? null : guardarProfesor,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar docente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
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

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: ListaAdminRegistros(
                  key: ValueKey(_versionLista),
                  tipo: 'docentes',
                  titulo: 'Docentes registrados',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET REUTILIZABLE PARA CAMPOS
  Widget _campo(
    String titulo,
    String hint,
    IconData icono, {
    bool ocultar = false,
    required TextEditingController controller,
    TextInputType tipo = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: ocultar,
          keyboardType: tipo,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icono, color: Colors.deepPurple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
