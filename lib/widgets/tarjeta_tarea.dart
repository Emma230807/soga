
import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TarjetaTarea extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;

  const TarjetaTarea({
    super.key,
    required this.tarea,
    required this.onCambiarEstado,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          // CASILLA PARA COMPLETAR LA TAREA
          Checkbox(
            value: tarea.completada,
            activeColor: Colors.deepPurple,
            onChanged: (valor) {
              onCambiarEstado();
            },
          ),

          // LÍNEA DE COLOR
          Container(
            width: 3,
            height: 35,
            decoration: BoxDecoration(
              color: tarea.completada
                  ? Colors.green
                  : Colors.deepPurple,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          SizedBox(width: 12),

          // INFORMACIÓN DE LA TAREA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarea.titulo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: tarea.completada
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  tarea.fechaEntrega,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // BOTÓN PARA ELIMINAR LA TAREA
          IconButton(
            onPressed: onEliminar,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
