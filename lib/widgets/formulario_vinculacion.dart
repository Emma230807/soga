import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Vincula un alumno a una de las relaciones grupo-materia del docente.
/// Devuelve `true` al cerrar el diálogo si la inscripción se realizó.
class FormularioVinculacion extends StatefulWidget {
  const FormularioVinculacion({super.key});

  @override
  State<FormularioVinculacion> createState() => _FormularioVinculacionState();
}

class _FormularioVinculacionState extends State<FormularioVinculacion> {
  final TextEditingController codigoController = TextEditingController();
  late final Future<List<Map<String, dynamic>>> _relaciones;
  String? _claveSeleccionada;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _relaciones = _cargarRelaciones();
  }

  Future<List<Map<String, dynamic>>> _cargarRelaciones() async {
    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) {
      throw StateError('Debes iniciar sesión como profesor.');
    }
    final respuesta = await client.rpc('soga_docente_grupos');
    if (respuesta is! List) {
      throw const FormatException('No se recibieron relaciones del profesor.');
    }
    return respuesta
        .map((valor) => Map<String, dynamic>.from(valor as Map))
        .toList();
  }

  String _clave(Map<String, dynamic> fila) =>
      '${fila['idGrupo']}|${fila['idMateria']}';

  Future<void> _agregarAlumno(List<Map<String, dynamic>> relaciones) async {
    if (_guardando) return;

    final matricula = codigoController.text.trim();

    if (!RegExp(r'^\d{10}$').hasMatch(matricula)) {
      setState(() {
        _error = 'Ingresa una matrícula de 10 dígitos.';
      });
      return;
    }

    final seleccion = _claveSeleccionada;
    final coincidencias = relaciones.where((r) => _clave(r) == seleccion);

    if (coincidencias.isEmpty) {
      setState(() {
        _error = 'Selecciona un grupo y una materia.';
      });
      return;
    }

    final relacion = coincidencias.first;

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.rpc(
        'soga_docente_vincular_alumno',
        params: {
          'p_matricula': matricula,
          'p_id_grupo': relacion['idGrupo'],
          'p_id_materia': (relacion['idMateria'] as num).toInt(),
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      if (!mounted) return;

      final mensaje = e.message.toLowerCase();

      if (mensaje.contains('ya está inscrito')) {
        setState(() {
          _error = 'Este alumno ya está inscrito en el grupo y materia seleccionados.';
        });
      } else if (mensaje.contains('ya pertenece a otra inscripción')) {
        setState(() {
          _error = 'Este alumno ya pertenece a otro grupo o materia.';
        });
      } else if (mensaje.contains('no existe un alumno')) {
        setState(() {
          _error = 'No existe un alumno con esa matrícula.';
        });
      } else {
        setState(() {
          _error = 'No se pudo agregar al alumno: ${e.message}';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Ocurrió un error al agregar al alumno.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar alumno'),
      content: SizedBox(
        width: 380,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _relaciones,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text(
                'No se pudieron cargar los grupos: ${snapshot.error}',
              );
            }
            final relaciones = snapshot.data ?? [];
            if (relaciones.isEmpty) {
              return const Text('No tienes grupos y materias asignados.');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona dónde inscribir al alumno.'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _claveSeleccionada,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Grupo y materia',
                    prefixIcon: const Icon(
                      Icons.groups,
                      color: Color(0xFF7043FF),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: relaciones.map((fila) {
                    return DropdownMenuItem<String>(
                      value: _clave(fila),
                      child: Text(
                        '${fila['nombreGrupo']} · ${fila['materia']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) => setState(() => _claveSeleccionada = valor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codigoController,
                  enabled: !_guardando,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Matrícula del alumno',
                    hintText: '2026001234',
                    prefixIcon: const Icon(Icons.person_search),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _guardando
                          ? null
                          : () => _agregarAlumno(relaciones),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7043FF),
                        foregroundColor: Colors.white,
                      ),
                      child: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Agregar'),
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
