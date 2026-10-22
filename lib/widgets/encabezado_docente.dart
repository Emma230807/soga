import 'package:flutter/material.dart';
import 'package:soga/models/docente.dart';
import 'package:soga/views/pantalla_login.dart';

class EncabezadoDocente extends StatelessWidget {
  final Docente docente;

  const EncabezadoDocente({super.key, required this.docente});

  String obtenerIniciales(String nombre) {
    final palabras = nombre.trim().split(RegExp(r'\s+'));

    if (palabras.first.isEmpty) {
      return '';
    }

    if (palabras.length == 1) {
      return palabras.first[0].toUpperCase();
    }

    return '${palabras.first[0]}${palabras.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 23),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PANEL DOCENTE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    obtenerIniciales(docente.nombre),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prof. ${docente.nombre}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Matemáticas y Física · Secundaria',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),

                      const SizedBox(height: 8),

                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Color(0xFF36E0AC),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '3 grupos asignados',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
