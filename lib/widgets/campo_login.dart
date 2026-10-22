import 'package:flutter/material.dart';

class CampoLogin extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool esContrasena;
  final TextEditingController controller;

  const CampoLogin({
    super.key,
    required this.texto,
    required this.icono,
    required this.controller,
    this.esContrasena = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: esContrasena,
      decoration: InputDecoration(
        hintText: texto,
        prefixIcon: Icon(icono),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
