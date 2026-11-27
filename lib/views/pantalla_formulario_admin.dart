import 'package:flutter/material.dart';
import 'package:soga/views/carga_administradores.dart';

/// Mantiene la ruta antigua y reutiliza la pantalla de administración vigente.
/// Así no se mantienen dos formularios con flujos de registro distintos.
class PantallaFormularioAdmin extends StatelessWidget {
  const PantallaFormularioAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const CargaAdministradores();
  }
}
