
import 'package:flutter/material.dart';
import 'package:soga/views/pantalla_AgregarNota.dart';
import 'package:soga/controllers/notas_controller.dart';
import 'package:soga/models/nota.dart';
import 'package:soga/widgets/tarjeta_nota.dart';

class PantallaNotas extends StatefulWidget {
  const PantallaNotas({super.key});

  @override
  State<PantallaNotas> createState() => _PantallaNotas();
}

class _PantallaNotas extends State<PantallaNotas> {

  final NotasController controller = NotasController();

  List<Nota> notas = [];

  @override
  void initState() {
    super.initState();
    notas = controller.obtenerNotas();
  }

  // ABRIR PANTALLA PARA AGREGAR NOTAS
  Future<void> abrirANotas() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaAgregarnota(),
      ),
    );

    if (!mounted) return;

    setState(() {
      notas = controller.obtenerNotas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepPurple,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        title: Text(
          "Mis notas",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.deepPurple,
            ),
            child: IconButton(
              onPressed: abrirANotas,
              icon: Icon(Icons.add),
              color: Colors.white,
            ),
          ),
        ],
      ),

      // MOSTRAR LAS NOTAS
      body: notas.isEmpty
          ? Center(
              child: Text("No tienes notas todavía"),
            )
          : ListView.builder(
              itemCount: notas.length,
              itemBuilder: (context, index) {
                return TarjetaNota(
                  nota: notas[index],
                );
              },
            ),
    );
  }
}
