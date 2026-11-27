import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/models/grupo.dart';
import 'package:soga/datasourses/grupos_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AltaGrupo extends StatefulWidget {
  const AltaGrupo({super.key});

  @override
  State<AltaGrupo> createState() => _AltaGrupoState();
}

class _AltaGrupoState extends State<AltaGrupo> {
  final TextEditingController idGrupoController = TextEditingController();
  final TextEditingController nombreGrupoController = TextEditingController();
  bool guardando = false;
  late Future<List<Map<String, dynamic>>> _grupos;
  bool _eliminando = false;

  @override
  void initState() {
    super.initState();
    _grupos = _obtenerGrupos();
  }

  Future<List<Map<String, dynamic>>> _obtenerGrupos() async {
    final respuesta = await Supabase.instance.client.rpc(
      'soga_admin_listar_grupos',
    );
    if (respuesta is! List) {
      throw const FormatException('La consulta no devolvió una lista');
    }
    return respuesta
        .map((fila) => Map<String, dynamic>.from(fila as Map))
        .toList();
  }

  Future<void> _actualizarGrupos() async {
    setState(() => _grupos = _obtenerGrupos());
    try {
      await _grupos;
    } catch (_) {
      // El error se presenta en el FutureBuilder.
    }
  }

  Future<void> _eliminarGrupo(Map<String, dynamic> grupo) async {
    if (_eliminando) return;
    final id = (grupo['idGrupo'] ?? '').toString();
    final nombre = (grupo['nombreGrupo'] ?? '').toString();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          '¿Quieres eliminar el grupo "$id - $nombre"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmado != true) return;

    setState(() => _eliminando = true);
    try {
      await Supabase.instance.client.rpc(
        'soga_admin_eliminar_grupo',
        params: {'p_id_grupo': id},
      );
      if (!mounted) return;
      mostrarMensaje('Grupo eliminado correctamente');
      await _actualizarGrupos();
    } on PostgrestException catch (e) {
      if (mounted) mostrarMensaje('No se pudo eliminar: ${e.message}');
    } catch (e) {
      if (mounted) mostrarMensaje('No se pudo eliminar el grupo: $e');
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  Widget _listaGrupos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Grupos registrados',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'Actualizar grupos',
              onPressed: _eliminando ? null : _actualizarGrupos,
              icon: const Icon(Icons.refresh, color: Colors.deepPurple),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _grupos,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No se pudieron cargar los grupos: ${snapshot.error}'),
                  TextButton(
                    onPressed: _actualizarGrupos,
                    child: const Text('Reintentar'),
                  ),
                ],
              );
            }
            final grupos = snapshot.data ?? [];
            if (grupos.isEmpty) {
              return const Text('No hay grupos registrados.');
            }
            return Column(
              children: [
                for (final grupo in grupos)
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEDE4FF),
                        child: Icon(
                          Icons.groups_outlined,
                          color: Colors.deepPurple,
                        ),
                      ),
                      title: Text(
                        (grupo['idGrupo'] ?? '').toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text((grupo['nombreGrupo'] ?? '').toString()),
                      trailing: IconButton(
                        tooltip: 'Eliminar grupo',
                        onPressed: _eliminando
                            ? null
                            : () => _eliminarGrupo(grupo),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> guardarGrupo() async {
    final id = idGrupoController.text.trim();
    final nombre = nombreGrupoController.text.trim();

    if (id.isEmpty || nombre.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final grupo = Grupo(idGrupo: id, nombreGrupo: nombre);

      await GruposSupabase.registrarGrupo(grupo);

      if (!mounted) return;

      idGrupoController.clear();
      nombreGrupoController.clear();

      mostrarMensaje('Grupo registrado correctamente');
      await _actualizarGrupos();
    } on PostgrestException catch (e) {
      if (!mounted) return;

      if (e.code == '23505') {
        mostrarMensaje('El ID del grupo ya existe');
      } else {
        mostrarMensaje('Error: ${e.message}');
      }
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje('Error al registrar el grupo');
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    idGrupoController.dispose();
    nombreGrupoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FF),

      body: SingleChildScrollView(
        child: Column(
          children: [
            EncabezadoSoga(
              titulo: "Agregar grupo",
              accion: "Registrar nuevo grupo",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ENCABEZADO DEL FORMULARIO
                  const Text(
                    "Datos del grupo",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Ingresa la información para registrar un nuevo grupo.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // ID DEL GRUPO
                  const Text(
                    "ID del grupo",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: idGrupoController,
                    decoration: InputDecoration(
                      hintText: "Ej. G001",
                      prefixIcon: const Icon(
                        Icons.numbers,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // NOMBRE DEL GRUPO
                  const Text(
                    "Nombre del grupo",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: nombreGrupoController,
                    decoration: InputDecoration(
                      hintText: "Ej. Desarrollo de Software 401",
                      prefixIcon: const Icon(
                        Icons.groups,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOTÓN AGREGAR GRUPO
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: guardando ? null : guardarGrupo,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Agregar grupo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _listaGrupos(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
