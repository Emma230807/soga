import 'package:flutter/material.dart';

class CampoLogin extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool esContrasena;

  const CampoLogin({
    super.key,
    required this.texto,
    required this.icono,
    this.esContrasena = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: esContrasena,
      decoration: InputDecoration(
        hintText: texto,
        prefixIcon: Icon(icono),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
