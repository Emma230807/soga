import 'package:flutter/material.dart';

class EncabezadoDocente extends StatelessWidget {
  const EncabezadoDocente({super.key});

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
                  onPressed: () {},
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
                  child: const Text(
                    'JP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prof. Javier Pérez',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Matemáticas y Física · Secundaria',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      SizedBox(height: 8),
                      Row(
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
