import 'package:flutter/material.dart';

class EncabezadoSoga extends StatefulWidget {
  final String titulo;
  final String accion;
  const EncabezadoSoga({super.key, required this.titulo, required this.accion});

  @override
  State<StatefulWidget> createState() => _EncabezadoSoga();
}

class _EncabezadoSoga extends State<EncabezadoSoga> {
  @override
  Widget build(BuildContext context) {
    return // ENCABEZADO MORADO
    Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF824DFF), Color(0xFFA56AFF)],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BOTÓN REGRESAR
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(height: 15),

          const Text(
            'SOGA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            widget.titulo,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.accion,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
