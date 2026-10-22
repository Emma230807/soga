import 'package:flutter/material.dart';
import 'package:soga/views/homeAlumno.dart';
import 'package:soga/views/home_administrador.dart';

import 'package:soga/widgets/campo_login.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/views/home_docente.dart';

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

  // MÉTODO PARA INICIAR SESIÓN
  void iniciarSesion() {
    String correo = correoController.text.trim();
    String contrasena = contrasenaController.text;

    // VALIDAR CAMPOS VACÍOS
    if (correo.isEmpty || contrasena.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    // VALIDAR CREDENCIALES EN DATOS TEMPORALES
    final usuario = DatosTemporales.iniciarSesion(correo, contrasena);

    // COMPROBAR SI EXISTE EL USUARIO
    if (usuario == null) {
      mostrarMensaje('Correo o contraseña incorrectos');
      return;
    }

    // IDENTIFICAR EL TIPO DE USUARIO
    switch (usuario.rol) {
      // DOCENTE
      case RolUsuario.docente:
        final docente = DatosTemporales.validarDocente(correo, contrasena);

        if (docente != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDocente(docente: docente),
            ),
          );
        }
        break;

      // ALUMNO OSWA, aqui va el apartado de alumno
      case RolUsuario.alumno:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAlumno()),
        );
        break;

      // ADMINISTRADOR
      case RolUsuario.administrador:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAdministrador()),
        );
        break;
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

              onPressed: iniciarSesion,

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
