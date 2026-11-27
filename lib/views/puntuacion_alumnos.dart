import 'package:flutter/material.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:soga/widgets/formulario_asignar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Muestra tareas personales y cumplimiento de actividades del profesor.
/// Estos porcentajes no son calificaciones oficiales.
class PuntuacionAlumnos extends StatefulWidget {
  const PuntuacionAlumnos({super.key});

  @override
  State<PuntuacionAlumnos> createState() => _PuntuacionAlumnosState();
}

class _DatosAvance {
  final List<Map<String, dynamic>> relaciones;
  final List<Map<String, dynamic>> alumnos;
  final List<Map<String, dynamic>> actividades;

  const _DatosAvance({
    required this.relaciones,
    required this.alumnos,
    required this.actividades,
  });
}

class _PuntuacionAlumnosState extends State<PuntuacionAlumnos> {
  late Future<_DatosAvance> _consulta;
  String? _relacionSeleccionada;

  @override
  void initState() {
    super.initState();
    _consulta = _cargar();
  }

  Future<_DatosAvance> _cargar() async {
    final supabase = Supabase.instance.client;
    if (supabase.auth.currentUser == null) {
      throw StateError(
        'Inicia sesion como profesor para consultar los alumnos.',
      );
    }

    final respuestas = await Future.wait<dynamic>([
      supabase.rpc('soga_docente_grupos'),
      supabase.rpc('soga_docente_alumnos'),
      supabase.rpc('soga_docente_consultar_actividades'),
    ]);

    List<Map<String, dynamic>> convertir(dynamic datos) {
      if (datos is! List) {
        throw const FormatException('Supabase no devolvio una lista valida.');
      }
      return datos
          .map((dato) => Map<String, dynamic>.from(dato as Map))
          .toList();
    }

    return _DatosAvance(
      relaciones: convertir(respuestas[0]),
      alumnos: convertir(respuestas[1]),
      actividades: convertir(respuestas[2]),
    );
  }

  void _actualizar() {
    setState(() => _consulta = _cargar());
  }

  Future<void> _recargar() async {
    _actualizar();
    try {
      await _consulta;
    } catch (_) {
      // El FutureBuilder muestra los errores.
    }
  }

  Future<void> _abrirFormularioAsignar() async {
    final registrado = await showDialog<bool>(
      context: context,
      builder: (_) => const FormularioAsignarActividad(),
    );
    if (!mounted) return;
    if (registrado == true) {
      _actualizar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad asignada correctamente.')),
      );
    }
  }

  String _clave(Map<String, dynamic> relacion) =>
      '${relacion['idGrupo']}|${relacion['idMateria']}';

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Widget _tarjeta(
    Map<String, dynamic> alumno,
    List<Map<String, dynamic>> actividades,
  ) {
    final nombre = (alumno['nombre'] as String?)?.trim() ?? 'Sin nombre';
    final total = (alumno['total'] as num?)?.toInt() ?? 0;
    final completadas = (alumno['completadas'] as num?)?.toInt() ?? 0;
    final progreso = total <= 0 ? 0.0 : (completadas / total).clamp(0.0, 1.0);
    final matricula = alumno['matricula']?.toString();
    final asignadas = actividades
        .where(
          (a) => matricula != null && a['matricula']?.toString() == matricula,
        )
        .toList();
    final hechas = asignadas.where((a) => a['estado'] == true).length;
    final cumplimiento = asignadas.isEmpty ? 0.0 : hechas / asignadas.length;

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF7648FF),
                  child: Text(
                    _iniciales(nombre),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  total == 0 ? '0 %' : '${(progreso * 100).round()} %',
                  style: const TextStyle(
                    color: Color(0xFF7043FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              '$completadas de $total tareas completadas',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: const Color(0xFFECE9FF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const Text(
              'Actividades del profesor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$hechas de ${asignadas.length} actividades completadas '
              '(${(cumplimiento * 100).round()} %)',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: cumplimiento,
                minHeight: 8,
                backgroundColor: const Color(0xFFECE9FF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7043FF),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (asignadas.isEmpty)
              const Text(
                'Aún no tiene actividades asignadas.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...asignadas.map((actividad) {
                final realizada = actividad['estado'] == true;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(
                        realizada
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: realizada
                            ? Colors.green
                            : const Color(0xFF9279C8),
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          actividad['actividad']?.toString() ??
                              'Sin descripción',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        realizada ? 'Completada' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 12,
                          color: realizada
                              ? Colors.green.shade700
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: Column(
        children: [
          EncabezadoSoga(titulo: 'Puntuación de alumnos', accion: ''),
          Expanded(
            child: FutureBuilder<_DatosAvance>(
              future: _consulta,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.deepPurple,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se pudo cargar el avance: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _actualizar,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final datos = snapshot.data!;
                if (datos.relaciones.isEmpty) {
                  return const Center(
                    child: Text('No tienes grupos y materias asignados.'),
                  );
                }

                final claves = datos.relaciones.map(_clave).toSet();
                final seleccion = claves.contains(_relacionSeleccionada)
                    ? _relacionSeleccionada!
                    : _clave(datos.relaciones.first);
                final actividadesGrupo = datos.actividades.where((actividad) {
                  return '${actividad['idGrupo']}|${actividad['idMateria']}' ==
                      seleccion;
                }).toList();
                final alumnos =
                    datos.alumnos.where((alumno) {
                      return alumno['cveInscripcion']?.toString() == seleccion;
                    }).toList()..sort(
                      (a, b) => (a['nombre']?.toString() ?? '').compareTo(
                        b['nombre']?.toString() ?? '',
                      ),
                    );

                return RefreshIndicator(
                  onRefresh: _recargar,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _abrirFormularioAsignar,
                          icon: const Icon(Icons.assignment_outlined),
                          label: const Text('Asignar actividad'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7043FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                        items: datos.relaciones.map((relacion) {
                          return DropdownMenuItem<String>(
                            value: _clave(relacion),
                            child: Text(
                              '${relacion['nombreGrupo']} · ${relacion['materia']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() => _relacionSeleccionada = valor);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${alumnos.length} ${alumnos.length == 1 ? 'alumno' : 'alumnos'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar',
                            onPressed: _actualizar,
                            icon: const Icon(
                              Icons.refresh,
                              color: Color(0xFF7043FF),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Avance de tareas de la materia. No equivale a una calificación.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      if (alumnos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 35),
                          child: Center(
                            child: Text(
                              'No hay alumnos inscritos en esta relación.',
                            ),
                          ),
                        )
                      else
                        ...alumnos.map(
                          (alumno) => _tarjeta(alumno, actividadesGrupo),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
