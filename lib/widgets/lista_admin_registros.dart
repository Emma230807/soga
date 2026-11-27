import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lista administrativa: docentes, materias o asignaciones de docente/grupo/materia.
class ListaAdminRegistros extends StatefulWidget {
  final String tipo;
  final String titulo;
  const ListaAdminRegistros({super.key, required this.tipo, required this.titulo});

  @override
  State<ListaAdminRegistros> createState() => _ListaAdminRegistrosState();
}

class _ListaAdminRegistrosState extends State<ListaAdminRegistros> {
  late Future<List<Map<String, dynamic>>> _consulta;
  bool _borrando = false;

  @override
  void initState() {
    super.initState();
    _actualizar();
  }

  void _actualizar() {
    _consulta = _consultar();
    if (mounted) setState(() {});
  }

  Future<List<Map<String, dynamic>>> _consultar() async {
    final respuesta = await Supabase.instance.client.rpc(
      'soga_admin_listar', params: {'p_tipo': widget.tipo},
    );
    if (respuesta is! List) {
      throw const FormatException('Respuesta inesperada del servidor');
    }
    return respuesta.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _eliminar(Map<String, dynamic> registro) async {
    if (_borrando) return;
    final nombre = (registro['titulo'] ?? '').toString();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Eliminar «$nombre»? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    setState(() => _borrando = true);
    try {
      if (widget.tipo == 'docentes') {
        final resultado = await Supabase.instance.client.functions.invoke(
          'soga-admin-eliminar-cuenta',
          body: {'tipo': widget.tipo, 'id': registro['id'].toString()},
        );
        if (resultado.status < 200 || resultado.status >= 300 ||
            (resultado.data is Map && resultado.data['ok'] != true)) {
          throw Exception(resultado.data is Map
              ? (resultado.data['error'] ?? 'No se pudo eliminar el docente')
              : 'No se pudo eliminar el docente');
        }
      } else {
        await Supabase.instance.client.rpc(
          'soga_admin_eliminar',
          params: {'p_tipo': widget.tipo, 'p_id': registro['id'].toString()},
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro eliminado correctamente')),
      );
      _actualizar();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $error')),
      );
    } finally {
      if (mounted) setState(() => _borrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(widget.titulo,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
          IconButton(
            tooltip: 'Actualizar lista',
            onPressed: _borrando ? null : _actualizar,
            icon: const Icon(Icons.refresh, color: Colors.deepPurple),
          ),
        ]),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _consulta,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Column(children: [
                Text('Error al consultar registros: ${snapshot.error}'),
                TextButton(onPressed: _actualizar, child: const Text('Reintentar')),
              ]);
            }
            final registros = snapshot.data!;
            if (registros.isEmpty) return const Text('No hay registros.');
            return Column(children: [
              for (final registro in registros)
                Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEDE4FF),
                      child: Icon(Icons.person_outline, color: Colors.deepPurple),
                    ),
                    title: Text((registro['titulo'] ?? '').toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text((registro['subtitulo'] ?? '').toString()),
                    trailing: IconButton(
                      tooltip: 'Eliminar',
                      onPressed: _borrando ? null : () => _eliminar(registro),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ),
                ),
            ]);
          },
        ),
      ],
    );
  }
}
