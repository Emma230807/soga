import 'package:flutter/material.dart';
import 'package:soga/datasourses/administradores_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaFormularioAdmin extends StatefulWidget {
  const PantallaFormularioAdmin({super.key});

  @override
  State<PantallaFormularioAdmin> createState() =>
      _PantallaFormularioAdminState();
}

class _PantallaFormularioAdminState extends State<PantallaFormularioAdmin> {
  final nombreController = TextEditingController();
  final numeroEmpleadoController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmarContrasenaController = TextEditingController();

  bool guardando = false;

  @override
  void dispose() {
    nombreController.dispose();
    numeroEmpleadoController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> guardarAdministrador() async {
    if (guardando) return;

    final nombre = nombreController.text.trim();
    final numeroEmpleado = numeroEmpleadoController.text.trim();
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text;
    final confirmar = confirmarContrasenaController.text;

    if (nombre.isEmpty ||
        numeroEmpleado.isEmpty ||
        correo.isEmpty ||
        contrasena.trim().isEmpty ||
        confirmar.trim().isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    if (contrasena.length < 8) {
      mostrarMensaje('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    if (contrasena != confirmar) {
      mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await AdministradoresSupabase.registrarAdministrador(
        nombre: nombre,
        numeroEmpleado: numeroEmpleado,
        correo: correo,
        contrasena: contrasena,
      );

      if (!mounted) return;

      nombreController.clear();
      numeroEmpleadoController.clear();
      correoController.clear();
      contrasenaController.clear();
      confirmarContrasenaController.clear();

      mostrarMensaje('Administrador registrado correctamente');
    } on FunctionException catch (e) {
      if (!mounted) return;

      debugPrint('Código: ${e.status}');
      debugPrint('Detalles: ${e.details}');

      final detalles = e.details;

      mostrarMensaje(
        detalles is Map
            ? '${detalles['mensaje'] ?? 'Error al registrar'}'
            : 'Error al registrar: ${e.status}',
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Error: $e');
      mostrarMensaje('Error al registrar administrador');
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
            // ENCABEZADO MORADO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 45,
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
                  // BOTÓN REGRESAR
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                    'Agregar administrador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Registra un nuevo administrador en el sistema.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // CUERPO DEL FORMULARIO
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del administrador',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  // TARJETA BLANCA
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOMBRE COMPLETO
                        const Text(
                          'Nombre completo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            hintText: 'Ej. María López',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // NÚMERO DE EMPLEADO
                        const Text(
                          'Número de empleado',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: numeroEmpleadoController,
                          decoration: InputDecoration(
                            hintText: 'Ej. ADM-001',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // CORREO
                        const Text(
                          'Correo electrónico',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'administrador@correo.com',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // CONTRASEÑA
                        const Text(
                          'Contraseña',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: contrasenaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Ingresa una contraseña',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // CONFIRMAR CONTRASEÑA
                        const Text(
                          'Confirmar contraseña',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: confirmarContrasenaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Repite la contraseña',
                            prefixIcon: const Icon(
                              Icons.lock_reset_outlined,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ROL ASIGNADO
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings_outlined,
                                color: Colors.deepPurple,
                              ),

                              SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  'Rol: Administrador',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BOTÓN GUARDAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: guardando ? null : guardarAdministrador,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar administrador'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
