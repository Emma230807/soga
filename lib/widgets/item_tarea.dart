import 'package:flutter/material.dart';

import '../models/tarea.dart';

class ItemTarea extends StatelessWidget {
  final Tarea tarea;

  const ItemTarea({super.key, required this.tarea});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Color(0xFF7648FF), size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarea.titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF241D36),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Entrega: ${tarea.fechaEntrega}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF858099),
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.access_time, color: Color(0xFFFF9B43), size: 18),
        ],
      ),
    );
  }
}
