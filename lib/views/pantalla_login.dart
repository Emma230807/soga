
import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_login.dart';
import 'package:soga/widgets/formulario_login.dart';
import 'package:soga/views/registro_usuario.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      resizeToAvoidBottomInset: true,

      body: SingleChildScrollView(
        child: Stack(
          children: [
            EncabezadoLogin(),

            Column(
              children: [
                const SizedBox(height: 300),

                FormularioLogin(),

                const SizedBox(height: 20),

                // BOTÓN DE REGISTRO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No tienes una cuenta?",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PantallaRegistroAlumno(),
                          ),
                        );
                      },
                      child: const Text(
                        "Regístrate",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
