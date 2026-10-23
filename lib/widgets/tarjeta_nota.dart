import 'package:flutter/material.dart';
import 'package:soga/models/nota.dart';

class TarjetaNota extends StatelessWidget {
  final Nota nota;

  const TarjetaNota({
    super.key,
    required this.nota,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: nota.color,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nota.titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(nota.contenido),
          ],
        ),
      ),
    );
  }
}