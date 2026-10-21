import 'package:flutter/material.dart';
import 'package:soga/views/pantalla_AgregarNota.dart';
import 'package:soga/views/pantalla_login.dart';

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaAgregarnota(),
    );
  }
}
