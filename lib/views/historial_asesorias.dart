import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/widgets/tarjeta_asesoria.dart';

class HistorialAsesorias extends StatefulWidget {
  const HistorialAsesorias({super.key});

  @override
  State<HistorialAsesorias> createState() => _HistorialAsesorias();
}

class _HistorialAsesorias extends State<HistorialAsesorias> {
  final asesorias = DatosTemporales.asesorias;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: Column(
        children: [
          EncabezadoSoga(titulo: "Historial de asesorías", accion: ""),

          Expanded(
            child: asesorias.isEmpty
                ? const Center(
                    child: Text(
                      "No hay asesorías todavía",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: asesorias.length,
                    itemBuilder: (context, index) {
                      return TarjetaAsesoria(asesoria: asesorias[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
