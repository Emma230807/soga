import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/nota.dart';
import 'package:soga/widgets/selectorcolores.dart';

class PantallaAgregarnota extends StatefulWidget {
  final Nota? notaInicial;

  const PantallaAgregarnota({super.key, this.notaInicial});

  @override
  State<PantallaAgregarnota> createState() => _PantallaAgregarnotaState();
}

class _PantallaAgregarnotaState extends State<PantallaAgregarnota> {
  final tituloController = TextEditingController();
  final notaController = TextEditingController();
  Color colorSeleccionado = Colors.white;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final nota = widget.notaInicial;
    if (nota != null) {
      tituloController.text = nota.titulo;
      notaController.text = nota.contenido;
      colorSeleccionado = nota.color;
    }
  }

  Future<void> guardarNota() async {
    if (_guardando) return;
    final titulo = tituloController.text.trim();
    final contenido = notaController.text.trim();
    if (titulo.isEmpty || contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el título y la nota')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      if (widget.notaInicial == null) {
        await DatosTemporales.guardarNotaSupabase(
          titulo: titulo,
          contenido: contenido,
          color: colorSeleccionado,
        );
      } else {
        await DatosTemporales.actualizarNotaSupabase(
          idNota: widget.notaInicial!.id,
          titulo: titulo,
          contenido: contenido,
          color: colorSeleccionado,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar la nota: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7043FF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.notaInicial == null ? 'Agregar nota' : 'Editar nota',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _guardando ? null : guardarNota,
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, color: Colors.white),
            label: Text(
              _guardando ? 'Guardando...' : 'Guardar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'MI ESPACIO ESCOLAR',
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Organiza, Aprende y Avanza',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Guarda tus ideas y apuntes en un solo lugar',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorSeleccionado,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Color de la nota',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SelectorColores(
                      colorSeleccionado: colorSeleccionado,
                      onSeleccionar: (color) =>
                          setState(() => colorSeleccionado = color),
                    ),
                    const Divider(height: 30),
                    TextField(
                      controller: tituloController,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        hintText: 'Título de la nota...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    TextField(
                      controller: notaController,
                      minLines: 9,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu nota...',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
