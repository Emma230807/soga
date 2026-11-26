import 'package:flutter/material.dart';
import 'package:soga/views/homeAlumno.dart';
import 'package:soga/views/home_administrador.dart';
import 'package:soga/views/home_docente.dart';
import 'package:soga/widgets/campo_login.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormularioLogin extends StatefulWidget {
  const FormularioLogin({super.key});

  @override
  State<FormularioLogin> createState() => _FormularioLoginState();
}

class _FormularioLoginState extends State<FormularioLogin> {
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();

  // MÉTODO PARA MOSTRAR MENSAJES
  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  bool _iniciandoSesion = false;

  // Autenticacion real con Supabase Auth y perfil en PostgreSQL.
  Future<void> iniciarSesion() async {
    if (_iniciandoSesion) return;
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text;

    if (correo.isEmpty || contrasena.isEmpty) {
      mostrarMensaje('Ingresa tu correo y contraseña');
      return;
    }

    setState(() => _iniciandoSesion = true);
    try {
      final usuario = await DatosTemporales.iniciarSesionSupabase(
        correo,
        contrasena,
      );

      if (!mounted) return;

      // PROBAR CONSULTA DE TAREAS DESDE SUPABASE
      if (usuario.rol == RolUsuario.alumno) {
        try {
          final tareas = await DatosTemporales.obtenerTareasSupabase();

          debugPrint('=== TAREAS DESDE SUPABASE ===');
          debugPrint('Total de tareas: ${tareas.length}');

          for (final tarea in tareas) {
            debugPrint('ID: ${tarea['idTarea']}');
            debugPrint('Título: ${tarea['titulo']}');
            debugPrint('Prioridad: ${tarea['prioridad']}');
            debugPrint('Matrícula: ${tarea['matricula']}');
            debugPrint('Completada: ${tarea['completada']}');
          }
        } catch (e) {
          debugPrint('Error al consultar tareas: $e');
        }
      }

      if (!mounted) return;

      Widget pantalla;

      switch (usuario.rol) {
        case RolUsuario.docente:
          pantalla = HomeDocente(
            docente: DatosTemporales.docenteDesdeSesion(usuario),
            usuario: usuario,
          );
          break;
        case RolUsuario.alumno:
          pantalla = HomeAlumno(usuario: usuario);
          break;
        case RolUsuario.administrador:
          pantalla = HomeAdministrador(usuario: usuario);
          break;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pantalla),
      );
    } on AuthException catch (e) {
      if (mounted) mostrarMensaje('No se pudo iniciar sesión: ${e.message}');
    } on PostgrestException catch (e) {
      if (mounted) mostrarMensaje('No se pudo cargar el perfil: ${e.message}');
    } catch (e) {
      if (mounted) mostrarMensaje('Error al iniciar sesión: $e');
    } finally {
      if (mounted) setState(() => _iniciandoSesion = false);
    }
  }

  // MOSTRAR MENSAJE DE REGISTRO
  Future<void> mostrarRegistroExitoso(
    BuildContext context,
    String mensaje,
    IconData icono,
    Color color,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 60),

              const SizedBox(height: 15),

              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: const BoxDecoration(
        color: Color(0xFFF2F0FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Iniciar sesión',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          const Text('Correo', style: TextStyle(fontSize: 16)),

          CampoLogin(
            texto: 'Ingresa tu correo',
            icono: Icons.mail_outline,
            controller: correoController,
          ),

          const SizedBox(height: 20),

          const Text('Contraseña', style: TextStyle(fontSize: 16)),

          CampoLogin(
            texto: 'Ingresa tu contraseña',
            icono: Icons.lock_outline,
            esContrasena: true,
            controller: contrasenaController,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7043FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onPressed: _iniciandoSesion ? null : iniciarSesion,

              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ingresar', style: TextStyle(color: Colors.white)),

                  SizedBox(width: 8),

                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
