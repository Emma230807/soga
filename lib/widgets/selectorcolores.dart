import 'package:flutter/material.dart';

class SelectorColores extends StatefulWidget {
  const SelectorColores({super.key});

  @override
  State<SelectorColores> createState() => _SelectorColoresState();
}

class _SelectorColoresState extends State<SelectorColores> {
  final List<Color> colores = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  int? indiceSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(colores.length, (index) {
        bool seleccionado = indiceSeleccionado == index;

        return InkWell(
          onTap: () {
            setState(() {
              indiceSeleccionado = index;
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colores[index],
              shape: BoxShape.circle,
              border: Border.all(
                color: seleccionado ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
            child: seleccionado
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }),
    );
  }
}
