import 'package:flutter/material.dart';
import 'package:soga/models/docente.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/views/historial_asesorias.dart';
import 'package:soga/views/puntuacion_alumnos.dart';
import 'package:soga/views/registro_asesorias.dart';
import 'package:soga/views/perfil.dart';
import 'package:soga/widgets/formulario_vinculacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Panel docente con información del profesor autenticado.
/// Requiere las funciones SQL soga_docente_grupos y soga_docente_alumnos.
class HomeDocente extends StatefulWidget {
  final Docente docente;
  final UsuarioSesion usuario;

  const HomeDocente({
    super.key,
    required this.docente,
    required this.usuario,
  });

  @override
  State<HomeDocente> createState() => _HomeDocenteState();
}

class _HomeDocenteState extends State<HomeDocente> {
  late Future<_DatosDocente> _consulta;
  String? _relacionSeleccionada;
  final Map<String, Future<Map<String, dynamic>>> _detalles = {};
  final Set<String> _operando = {};


  @override
  void initState() {
    super.initState();
    _consulta = _cargarDatos();
  }

  Future<_DatosDocente> _cargarDatos() async {
    final cliente = Supabase.instance.client;
    if (cliente.auth.currentUser == null) {
      throw StateError('Inicia sesión para consultar tus grupos.');
    }

    // Ambos RPC filtran los resultados con auth.uid() en PostgreSQL.
    final respuestas = await Future.wait<dynamic>([
      cliente.rpc('soga_docente_grupos'),
      cliente.rpc('soga_docente_alumnos'),
    ]);

    List<Map<String, dynamic>> convertir(dynamic respuesta) {
      if (respuesta is! List) {
        throw const FormatException('La consulta no devolvió una lista.');
      }
      return respuesta.map((fila) => Map<String, dynamic>.from(fila as Map)).toList();
    }

    return _DatosDocente(
      grupos: convertir(respuestas[0]),
      alumnos: convertir(respuestas[1]),
    );
  }

  Future<void> _actualizar() async {
    _detalles.clear();
    final consulta = _cargarDatos();
    setState(() => _consulta = consulta);
    try {
      await consulta;
    } catch (_) {
      // El error se presenta en FutureBuilder.
    }
  }

  Future<void> _abrirPantalla(Widget pantalla) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
    if (mounted) await _actualizar();
  }

  Future<void> _agregarAlumno() async {
    final agregado = await showDialog<bool>(
      context: context,
      builder: (_) => const FormularioVinculacion(),
    );
    if (!mounted || agregado != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alumno vinculado correctamente')),
    );
    await _actualizar();
  }

  String _claveAlumno(String matricula, String grupo, int materia) =>
      '$matricula|$grupo|$materia';

  Future<Map<String, dynamic>> _cargarDetalle(
    String matricula, String grupo, int materia,
  ) async {
    final respuesta = await Supabase.instance.client.rpc(
      'soga_docente_detalle_alumno',
      params: {
        'p_matricula': matricula,
        'p_id_grupo': grupo,
        'p_id_materia': materia,
      },
    );
    if (respuesta is! Map) {
      throw const FormatException('No se recibieron detalles del alumno');
    }
    return Map<String, dynamic>.from(respuesta);
  }

  void _abrirAlumno(String matricula, String grupo, int materia) {
    final clave = _claveAlumno(matricula, grupo, materia);
    _detalles.putIfAbsent(
      clave, () => _cargarDetalle(matricula, grupo, materia),
    );
    setState(() {});
  }

  void _recargarAlumno(String matricula, String grupo, int materia) {
    final clave = _claveAlumno(matricula, grupo, materia);
    setState(() {
      _detalles[clave] = _cargarDetalle(matricula, grupo, materia);
    });
  }

  Future<void> _cambiarActividad(
    String matricula, String grupo, int materia,
    int idActividad, bool estado,
  ) async {
    final clave = '$matricula|$idActividad';
    if (_operando.contains(clave)) return;
    setState(() => _operando.add(clave));
    try {
      await Supabase.instance.client.rpc(
        'soga_docente_cambiar_estado_actividad',
        params: {
          'p_matricula': matricula,
          'p_id_actividad': idActividad,
          'p_estado': estado,
        },
      );
      if (!mounted) return;
      _recargarAlumno(matricula, grupo, materia);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la actividad: $e')),
      );
    } finally {
      if (mounted) setState(() => _operando.remove(clave));
    }
  }

  Future<void> _eliminarActividad(
    String matricula, String grupo, int materia,
    int idActividad, String nombre,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: Text('¿Eliminar "$nombre" para este alumno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    final clave = '$matricula|$idActividad';
    if (_operando.contains(clave)) return;
    setState(() => _operando.add(clave));
    try {
      await Supabase.instance.client.rpc(
        'soga_docente_eliminar_actividad',
        params: {'p_matricula': matricula, 'p_id_actividad': idActividad},
      );
      if (!mounted) return;
      _recargarAlumno(matricula, grupo, materia);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la actividad: $e')),
      );
    } finally {
      if (mounted) setState(() => _operando.remove(clave));
    }
  }

  Widget _tarjetaAlumno(Map<String, dynamic> alumno, String grupo, int materia) {
    final nombre = (alumno['nombre'] ?? 'Alumno sin nombre').toString();
    final matricula = (alumno['matricula'] ?? '').toString();
    final clave = _claveAlumno(matricula, grupo, materia);
    final total = (alumno['total'] as num?)?.toInt() ?? 0;
    final completadas = (alumno['completadas'] as num?)?.toInt() ?? 0;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        key: ValueKey(clave),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEDE4FF),
          child: Icon(Icons.person_outline, color: Color(0xFF7043FF)),
        ),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Tareas completadas: $completadas/$total'),
        onExpansionChanged: (abierto) {
          if (abierto) _abrirAlumno(matricula, grupo, materia);
        },
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          if (_detalles[clave] == null)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Abre la tarjeta para consultar las tareas y actividades.'),
            )
          else
            FutureBuilder<Map<String, dynamic>>(
              future: _detalles[clave],
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Text('No se pudo cargar: ${snapshot.error}'),
                      TextButton(
                        onPressed: () => _recargarAlumno(matricula, grupo, materia),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  );
                }
                final datos = snapshot.data!;
                final tareas = (datos['tareas'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map)).toList();
                final actividades = (datos['actividades'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map)).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Text('TAREAS (solo lectura)',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: Color(0xFF7043FF))),
                    const SizedBox(height: 6),
                    if (tareas.isEmpty)
                      const Text('Sin tareas en esta materia.')
                    else
                      for (final tarea in tareas)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(
                            tarea['completada'] == true
                                ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: tarea['completada'] == true
                                ? Colors.green : Colors.grey,
                          ),
                          title: Text((tarea['titulo'] ?? 'Sin título').toString()),
                          subtitle: Text(
                            '${tarea['completada'] == true ? 'Completada' : 'Pendiente'}'
                            ' · Fecha: ${tarea['fecha'] ?? 'Sin fecha'}',
                          ),
                        ),
                    const Divider(height: 26),
                    const Text('ACTIVIDADES (administradas por el profesor)',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: Color(0xFF7043FF))),
                    const SizedBox(height: 6),
                    if (actividades.isEmpty)
                      const Text('Sin actividades asignadas.')
                    else
                      for (final actividad in actividades)
                        Row(
                          children: [
                            Checkbox(
                              value: actividad['estado'] == true,
                              activeColor: const Color(0xFF7043FF),
                              onChanged: _operando.contains(
                                  '$matricula|${actividad['idActividad']}')
                                  ? null
                                  : (valor) => _cambiarActividad(
                                      matricula, grupo, materia,
                                      (actividad['idActividad'] as num).toInt(),
                                      valor ?? false,
                                    ),
                            ),
                            Expanded(
                              child: Text((actividad['actividad'] ?? 'Sin nombre').toString()),
                            ),
                            IconButton(
                              tooltip: 'Eliminar actividad de este alumno',
                              onPressed: _operando.contains(
                                  '$matricula|${actividad['idActividad']}')
                                  ? null
                                  : () => _eliminarActividad(
                                      matricula, grupo, materia,
                                      (actividad['idActividad'] as num).toInt(),
                                      (actividad['actividad'] ?? 'Actividad').toString(),
                                    ),
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            ),
                          ],
                        ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _boton(String titulo, IconData icono, VoidCallback alPulsar) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: alPulsar,
        icon: Icon(icono),
        label: Text(titulo),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7648FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _claveRelacion(Map<String, dynamic> grupo) =>
      (grupo['cveInscripcion'] ?? '').toString();

  String _tituloRelacion(Map<String, dynamic> grupo) {
    final nombre = (grupo['nombreGrupo'] ?? 'Grupo sin nombre').toString();
    final materia = (grupo['materia'] ?? 'Materia sin nombre').toString();
    return '$nombre · $materia';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7043FF),
        foregroundColor: Colors.white,
        title: const Text('Panel docente'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizar,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: () => _abrirPantalla(
              PantallaPerfil(usuario: widget.usuario),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _actualizar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MI ESPACIO ESCOLAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hola, ${widget.usuario.nombre}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text('Profesor', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 5),
                  Text(
                    widget.usuario.correo,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ASESORÍAS',
                    style: TextStyle(
                      color: Color(0xFF858099),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _boton('Registrar asesoría', Icons.edit_calendar_outlined,
                      () => _abrirPantalla(RegistroAsesorias())),
                  const SizedBox(height: 10),
                  _boton('Historial de asesorías', Icons.history,
                      () => _abrirPantalla(HistorialAsesorias())),
                  const SizedBox(height: 24),
                  const Text(
                    'MIS RELACIONES Y ALUMNOS',
                    style: TextStyle(
                      color: Color(0xFF858099),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<_DatosDocente>(
                    future: _consulta,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(36),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            Text('No se pudieron cargar los grupos: ${snapshot.error}'),
                            TextButton(
                              onPressed: _actualizar,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        );
                      }
                      final datos = snapshot.data!;
                      if (datos.grupos.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Todavía no tienes grupos y materias asignados.'),
                        );
                      }
                      final claves = datos.grupos.map(_claveRelacion).toSet();
                      final seleccion = _relacionSeleccionada != null &&
                              claves.contains(_relacionSeleccionada)
                          ? _relacionSeleccionada!
                          : _claveRelacion(datos.grupos.first);
                      final alumnos = datos.alumnos.where((alumno) =>
                          (alumno['cveInscripcion'] ?? '').toString() == seleccion).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey(seleccion),
                            initialValue: seleccion,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Grupo y materia',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: datos.grupos.map((grupo) {
                              return DropdownMenuItem<String>(
                                value: _claveRelacion(grupo),
                                child: Text(
                                  _tituloRelacion(grupo),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (valor) => setState(() {
                              _relacionSeleccionada = valor;
                            }),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${alumnos.length} ${alumnos.length == 1 ? 'alumno inscrito' : 'alumnos inscritos'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (alumnos.isEmpty)
                            const Text('No hay alumnos inscritos en este grupo.')
                          else
                            for (final alumno in alumnos)
                              _tarjetaAlumno(
                                alumno,
                                (datos.grupos.firstWhere(
                                  (g) => _claveRelacion(g) == seleccion,
                                )['idGrupo']).toString(),
                                (datos.grupos.firstWhere(
                                  (g) => _claveRelacion(g) == seleccion,
                                )['idMateria'] as num).toInt(),
                              ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _boton('Agregar alumno', Icons.person_add_alt_1, _agregarAlumno),
                  const SizedBox(height: 12),
                  _boton('Ver avance de alumnos', Icons.bar_chart,
                      () => _abrirPantalla(PuntuacionAlumnos())),
                  const SizedBox(height: 14),
                  const Text(
                    'Las relaciones con alumnos se consultan desde Supabase. '
                    'No se utilizan los alumnos de prueba.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatosDocente {
  final List<Map<String, dynamic>> grupos;
  final List<Map<String, dynamic>> alumnos;

  const _DatosDocente({required this.grupos, required this.alumnos});
}
