import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Formulario para asignar una actividad a los alumnos inscritos en
/// una relación grupo-materia del profesor autenticado.
/// Devuelve true al cerrar si se asignó correctamente.
class FormularioAsignarActividad extends StatefulWidget {
  const FormularioAsignarActividad({super.key});

  @override
  State<FormularioAsignarActividad> createState() =>
      _FormularioAsignarActividadState();
}

class _FormularioAsignarActividadState extends State<FormularioAsignarActividad> {
  final TextEditingController _actividadController = TextEditingController();
  late final Future<List<Map<String, dynamic>>> _relaciones;
  String? _seleccion;
  String? _error;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _relaciones = _cargarRelaciones();
  }

  Future<List<Map<String, dynamic>>> _cargarRelaciones() async {
    final cliente = Supabase.instance.client;
    if (cliente.auth.currentUser == null) {
      throw StateError('Inicia sesión como profesor.');
    }
    final respuesta = await cliente.rpc('soga_docente_grupos');
    if (respuesta is! List) {
      throw const FormatException('No se pudieron leer los grupos del docente.');
    }
    return respuesta
        .map((fila) => Map<String, dynamic>.from(fila as Map))
        .toList();
  }

  String _clave(Map<String, dynamic> fila) =>
      '${fila['idGrupo']}|${fila['idMateria']}';

  Future<void> _guardar(List<Map<String, dynamic>> relaciones) async {
    if (_guardando) return;
    final actividad = _actividadController.text.trim();
    if (actividad.isEmpty || actividad.length > 150) {
      setState(() => _error = 'Ingresa una actividad de 1 a 150 caracteres.');
      return;
    }
    final seleccionadas = relaciones.where((fila) => _clave(fila) == _seleccion);
    if (seleccionadas.isEmpty) {
      setState(() => _error = 'Selecciona un grupo y una materia.');
      return;
    }
    final relacion = seleccionadas.first;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final resultado = await Supabase.instance.client.rpc(
        'soga_docente_asignar_actividad',
        params: {
          'p_grupo': relacion['idGrupo'] as String,
          'p_materia': (relacion['idMateria'] as num).toInt(),
          'p_actividad': actividad,
        },
      );
      if (!mounted) return;
      final cantidad = (resultado as num).toInt();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Actividad asignada a $cantidad ${cantidad == 1 ? 'alumno' : 'alumnos'}.'),
        ),
      );
      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo asignar la actividad. Revisa tu conexión.');
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _actividadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar actividad'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      content: SizedBox(
        width: 380,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _relaciones,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text('No se pudieron cargar los grupos: ${snapshot.error}');
            }
            final relaciones = snapshot.data ?? [];
            if (relaciones.isEmpty) {
              return const Text('Todavía no tienes grupos y materias asignados.');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Se asignará a todos los alumnos inscritos en la relación seleccionada.'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _seleccion,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Grupo y materia',
                    prefixIcon: const Icon(Icons.groups, color: Color(0xFF7043FF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: relaciones.map((fila) => DropdownMenuItem<String>(
                    value: _clave(fila),
                    child: Text(
                      '${fila['nombreGrupo']} · ${fila['materia']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) => setState(() => _seleccion = valor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _actividadController,
                  enabled: !_guardando,
                  maxLength: 150,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Actividad',
                    hintText: 'Realizar práctica de Flutter',
                    prefixIcon: const Icon(Icons.assignment_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _guardando ? null : () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _guardando ? null : () => _guardar(relaciones),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7043FF),
                        foregroundColor: Colors.white,
                      ),
                      child: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Asignar'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
