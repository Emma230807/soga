import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_login.dart';
import 'package:soga/widgets/formulario_login.dart';

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

            Column(children: [const SizedBox(height: 300), FormularioLogin()]),
          ],
        ),
      ),
    );
  }
}
