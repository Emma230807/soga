import 'package:flutter/material.dart';
import 'package:soga/widgets/selectorcolores.dart';

class PantallaAgregarnota extends StatefulWidget {
  const PantallaAgregarnota({super.key});

  @override
  State<PantallaAgregarnota> createState() => _PantallaAgregarnotaState();
}

class _PantallaAgregarnotaState extends State<PantallaAgregarnota> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  Color? colorSeleccionado;

  @override
  void dispose() {
    tituloController.dispose();
    notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 233, 252),

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),

        title: const Text('Notas'),

        backgroundColor: const Color.fromARGB(255, 236, 233, 252),

        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 214, 202, 252),
            ),
            onPressed: () {
              // Aquí irá la función para guardar la nota.
            },
            child: const Text(
              "Guardar",
              style: TextStyle(color: Color.fromARGB(255, 124, 93, 210)),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SelectorColores(),

              Divider(height: 30),

              TextField(
                controller: tituloController,
                style: const TextStyle(
                  color: Color.fromARGB(255, 127, 130, 161),
                ),
                decoration: const InputDecoration(
                  hintText: "Título de la nota...",
                  hintStyle: TextStyle(fontSize: 24),
                  border: InputBorder.none,
                ),
              ),

              Divider(),

              const SizedBox(height: 10),

              TextField(
                controller: notaController,
                style: const TextStyle(
                  color: Color.fromARGB(255, 127, 130, 161),
                ),
                decoration: const InputDecoration(
                  hintText: "Nota...",
                  border: InputBorder.none,
                ),
                minLines: 10,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
