import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Historial de asesorias del profesor que inicio sesion en Supabase.
class HistorialAsesorias extends StatefulWidget {
  const HistorialAsesorias({super.key});

  @override
  State<HistorialAsesorias> createState() => _HistorialAsesoriasState();
}

class _HistorialAsesoriasState extends State<HistorialAsesorias> {
  late Future<_DatosHistorial> _consulta;
  final Set<int> _respondiendo = {};

  @override
  void initState() {
    super.initState();
    _consulta = _cargar();
  }

  Future<_DatosHistorial> _cargar() async {
    final resultados = await Future.wait([
      DatosTemporales.obtenerAsesoriasDocenteSupabase(),
      DatosTemporales.obtenerMateriasAsesoriaSupabase(),
    ]);
    final asesorias = resultados[0];
    final materias = resultados[1];
    return _DatosHistorial(
      asesorias: asesorias,
      nombresMaterias: {
        for (final materia in materias)
          if (materia['idMateria'] is num)
            (materia['idMateria'] as num).toInt():
                materia['nombre']?.toString() ?? 'Sin nombre',
      },
    );
  }

  Future<void> _actualizar() async {
    final nuevaConsulta = _cargar();
    setState(() => _consulta = nuevaConsulta);
    try {
      await nuevaConsulta;
    } catch (_) {
      // FutureBuilder se encarga de mostrar el error.
    }
  }

  Future<void> _responder(int idAsesoria, String estado) async {
    if (_respondiendo.contains(idAsesoria)) return;
    final accion = estado == 'ACEPTADA' ? 'aceptar' : 'rechazar';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('¿Quieres $accion esta asesoría?'),
        content: Text(
          'La solicitud quedará ${estado.toLowerCase()}. '
          'Esta decisión no podrá cambiarse desde esta pantalla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(estado == 'ACEPTADA' ? 'Aceptar' : 'Rechazar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    setState(() => _respondiendo.add(idAsesoria));
    try {
      await Supabase.instance.client.rpc(
        'soga_docente_responder_asesoria',
        params: {'p_id_asesoria': idAsesoria, 'p_estado': estado},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud ${estado.toLowerCase()} correctamente'),
        ),
      );
      await _actualizar();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo responder la solicitud')),
      );
    } finally {
      if (mounted) setState(() => _respondiendo.remove(idAsesoria));
    }
  }

  String _formatearFecha(dynamic dato) {
    final fecha = DateTime.tryParse(dato?.toString() ?? '');
    if (fecha == null) return 'Sin fecha';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(dynamic dato) {
    final valor = dato?.toString() ?? '';
    if (valor.isEmpty) return 'Sin hora';
    return valor.length >= 5 ? valor.substring(0, 5) : valor;
  }

  Widget _dato(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: const Color(0xFF7043FF), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$etiqueta: $valor',
              style: const TextStyle(color: Color(0xFF514A60)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(Map<String, dynamic> asesoria, Map<int, String> materias) {
    final idAsesoria = (asesoria['idAsesoria'] as num).toInt();
    final estado = asesoria['estado']?.toString() ?? 'PENDIENTE';
    final origen = asesoria['origen']?.toString() ?? 'ALUMNO';
    final pendiente = estado == 'PENDIENTE' && origen == 'ALUMNO';
    final procesando = _respondiendo.contains(idAsesoria);
    final titulo = asesoria['titulo']?.toString().trim() ?? '';
    final alumno = asesoria['nombreCompletoAlumno']?.toString().trim() ?? '';
    final materiaId = (asesoria['idMateria'] as num?)?.toInt();
    final nombreMateria = materiaId == null
        ? 'Materia no especificada'
        : materias[materiaId] ?? 'Materia no disponible';

    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x307043FF),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: Color(0xFF7043FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo.isEmpty ? 'Asesoria academica' : titulo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF30254B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nombreMateria,
                        style: const TextStyle(color: Color(0xFF7043FF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(
                    estado == 'ACEPTADA'
                        ? 'Aceptada'
                        : estado == 'RECHAZADA'
                        ? 'Rechazada'
                        : 'Pendiente',
                  ),
                  backgroundColor: estado == 'ACEPTADA'
                      ? const Color(0xFFE4F5E9)
                      : estado == 'RECHAZADA'
                      ? const Color(0xFFFFE6E6)
                      : const Color(0xFFFFF2D5),
                ),
                Chip(
                  label: Text(
                    origen == 'PROFESOR'
                        ? 'Registrada por profesor'
                        : 'Solicitud de alumno',
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _dato(
              Icons.person_outline,
              'Alumno',
              alumno.isEmpty ? 'No especificado' : alumno,
            ),
            _dato(
              Icons.calendar_today_outlined,
              'Fecha',
              _formatearFecha(asesoria['fecha']),
            ),
            _dato(
              Icons.access_time_outlined,
              'Hora',
              _formatearHora(asesoria['hora']),
            ),
            if (pendiente) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: procesando
                          ? null
                          : () => _responder(idAsesoria, 'ACEPTADA'),
                      icon: const Icon(Icons.check),
                      label: const Text('Aceptar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7043FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: procesando
                          ? null
                          : () => _responder(idAsesoria, 'RECHAZADA'),
                      icon: const Icon(Icons.close),
                      label: const Text('Rechazar'),
                    ),
                  ),
                ],
              ),
              if (procesando) const LinearProgressIndicator(),
            ],
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
          const EncabezadoSoga(
            titulo: 'Historial de asesorías',
            accion: 'Consulta las asesorías de tus alumnos',
          ),
          Expanded(
            child: FutureBuilder<_DatosHistorial>(
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
                            size: 42,
                            color: Color(0xFF7043FF),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No se pudieron cargar las asesorías',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
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
                return RefreshIndicator(
                  onRefresh: _actualizar,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${datos.asesorias.length} asesoría(s)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF514A60),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar asesorías',
                            onPressed: _actualizar,
                            icon: const Icon(
                              Icons.refresh,
                              color: Color(0xFF7043FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (datos.asesorias.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_note_outlined,
                                size: 56,
                                color: Color(0xFF9279C8),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Todavía no tienes asesorías registradas',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        for (final asesoria in datos.asesorias)
                          _tarjeta(asesoria, datos.nombresMaterias),
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

class _DatosHistorial {
  final List<Map<String, dynamic>> asesorias;
  final Map<int, String> nombresMaterias;

  const _DatosHistorial({
    required this.asesorias,
    required this.nombresMaterias,
  });
}
