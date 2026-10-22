import 'package:flutter/material.dart';

class SelectorFecha extends StatelessWidget {
  final DateTime? fechaSeleccionada;
  final ValueChanged<DateTime> onSeleccionar;

  const SelectorFecha({
    super.key,
    required this.fechaSeleccionada,
    required this.onSeleccionar,
  });

  Future<void> seleccionarFecha(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      onSeleccionar(fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => seleccionarFecha(context),
      icon: Icon(Icons.calendar_today),
      label: Text(
        fechaSeleccionada == null
            ? "Seleccionar fecha"
            : "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}",
      ),
    );
  }
}
