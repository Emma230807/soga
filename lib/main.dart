
import 'package:flutter/material.dart';

import 'package:soga/views/pantalla_tareas.dart';



void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: PantallaTareas(),

    );
  }
}
