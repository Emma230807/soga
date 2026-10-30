import 'package:flutter/material.dart';
import 'package:soga/views/agregar_docentes.dart';
import 'package:soga/views/altaGrupo.dart';
import 'package:soga/views/carga_administradores.dart';
import 'package:soga/views/homeAlumno.dart';
import 'package:soga/views/pantalla_notas.dart';
import 'package:soga/views/pantalla_notificaciones.dart';
import 'package:soga/views/pantalla_tareas.dart';
import 'package:soga/views/registro_usuario.dart';
import 'package:soga/views/vista_splash.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_MX');
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
