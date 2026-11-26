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
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    // Utiliza la fecha seleccionada si sigue siendo válida.
    final fechaInicial =
        fechaSeleccionada != null && !fechaSeleccionada!.isBefore(hoy)
        ? fechaSeleccionada!
        : hoy;

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 5, 12, 31),
      locale: const Locale('es', 'MX'),
    );

    if (fecha != null) {
      onSeleccionar(fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => seleccionarFecha(context),
      icon: const Icon(Icons.calendar_today),
      label: Text(
        fechaSeleccionada == null
            ? 'Seleccionar fecha'
            : '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
      ),
    );
  }
}
