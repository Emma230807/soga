import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_login.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: Column(
        children: [
          EncabezadoLogin(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(children: [const SizedBox(height: 22)]),
            ),
          ),
        ],
      ),
    );
  }
}
