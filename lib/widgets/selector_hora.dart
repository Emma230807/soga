import 'package:flutter/material.dart';

class SelectorHora extends StatelessWidget {
  final TimeOfDay? horaSeleccionada;
  final ValueChanged<TimeOfDay> onSeleccionar;

  const SelectorHora({
    super.key,
    required this.horaSeleccionada,
    required this.onSeleccionar,
  });

  Future<void> seleccionarHora(BuildContext context) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: horaSeleccionada ?? TimeOfDay.now(),
    );

    if (hora != null) {
      onSeleccionar(hora);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => seleccionarHora(context),
      icon: Icon(Icons.access_time),
      label: Text(
        horaSeleccionada == null
            ? "Seleccionar hora"
            : horaSeleccionada!.format(context),
      ),
    );
  }
}
