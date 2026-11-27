import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/nota.dart';
import 'package:soga/views/pantalla_AgregarNota.dart';
import 'package:soga/widgets/tarjeta_nota.dart';

class PantallaNotas extends StatefulWidget {
  const PantallaNotas({super.key});

  @override
  State<PantallaNotas> createState() => _PantallaNotasState();
}

class _PantallaNotasState extends State<PantallaNotas> {
  List<Nota> _notas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Color _colorDesdeBD(dynamic valor) {
    final texto = (valor ?? '').toString().trim();
    if (texto.startsWith('#')) {
      final hex = texto.substring(1);
      final numero = int.tryParse(hex, radix: 16);
      if (numero != null && (hex.length == 6 || hex.length == 8)) {
        return Color(hex.length == 6 ? 0xFF000000 | numero : numero);
      }
    }
    return Colors.white;
  }

  Future<void> _cargarNotas() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
    try {
      final registros = await DatosTemporales.obtenerNotasSupabase();
      final nuevas = registros
          .map(
            (dato) => Nota(
              id: (dato['idNota'] as num).toInt(),
              titulo: dato['titulo'] as String? ?? '',
              contenido: dato['contenido'] as String? ?? '',
              color: _colorDesdeBD(dato['color']),
              fechaCreacion:
                  DateTime.tryParse(dato['fechaCreacion']?.toString() ?? '')
                      ?.toLocal() ??
                  DateTime.now(),
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _notas = nuevas;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _abrirEditor([Nota? nota]) async {
    final guardada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaAgregarnota(notaInicial: nota)),
    );
    if (!mounted) return;
    if (guardada == true) await _cargarNotas();
  }

  Future<void> _eliminarNota(Nota nota) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text(
          '¿Deseas eliminar "${nota.titulo}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    try {
      await DatosTemporales.eliminarNotaSupabase(nota.id);
      if (!mounted) return;
      await _cargarNotas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la nota: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Volver',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'Mis notas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Actualizar',
                        onPressed: _cargando ? null : _cargarNotas,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                      IconButton(
                        tooltip: 'Crear nota',
                        onPressed: () => _abrirEditor(),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'MI ESPACIO ESCOLAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Organiza, Aprende y Avanza',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tus notas y apuntes en un solo lugar.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _cargando
                          ? 'Cargando tus notas...'
                          : '${_notas.length} ${_notas.length == 1 ? 'nota guardada' : 'notas guardadas'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No se pudieron cargar las notas: $_error',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _cargarNotas,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _notas.isEmpty
                ? const Center(
                    child: Text(
                      'Todavía no tienes notas. Presiona + para crear una.',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarNotas,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                      itemCount: _notas.length,
                      itemBuilder: (context, index) {
                        final nota = _notas[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _abrirEditor(nota),
                                  child: TarjetaNota(nota: nota),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Eliminar nota',
                                onPressed: () => _eliminarNota(nota),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
