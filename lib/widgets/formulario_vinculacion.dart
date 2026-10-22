import 'package:flutter/material.dart';

class FormularioVinculacion extends StatefulWidget {
  const FormularioVinculacion({super.key});

  @override
  State<FormularioVinculacion> createState() => _FormularioVinculacionState();
}

class _FormularioVinculacionState extends State<FormularioVinculacion> {
  final TextEditingController codigoController = TextEditingController();

  @override
  void dispose() {
    codigoController.dispose();
    super.dispose();
  }

  void agregarAlumno() {
    final codigo = codigoController.text.trim().toUpperCase();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código del alumno')),
      );
      return;
    }

    // Devolver el código a HomeDocente
    Navigator.pop(context, codigo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar alumno'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Introduce el código del alumno que deseas agregar.'),

          const SizedBox(height: 16),

          TextField(
            controller: codigoController,

            decoration: InputDecoration(
              labelText: 'Código del alumno',
              hintText: 'ALU-0001',
              prefixIcon: const Icon(Icons.person_search),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),

        ElevatedButton(onPressed: agregarAlumno, child: const Text('Agregar')),
      ],
    );
  }
}
