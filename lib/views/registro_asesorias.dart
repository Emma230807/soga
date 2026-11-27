import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/encabezado_soga.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistroAsesorias extends StatefulWidget {
  const RegistroAsesorias({super.key});

  @override
  State<RegistroAsesorias> createState() => _RegistroAsesoriasState();
}

class _RegistroAsesoriasState extends State<RegistroAsesorias> {
  final TextEditingController _motivoController = TextEditingController();
  late Future<void> _carga;
  List<Map<String, dynamic>> _relaciones = [];
  List<Map<String, dynamic>> _alumnos = [];
  String? _relacionSeleccionada;
  String? _matriculaSeleccionada;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _carga = _cargarCatalogos();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  static List<Map<String, dynamic>> _convertirFilas(dynamic dato) {
    if (dato == null) return [];
    return (dato as List)
        .map((fila) => Map<String, dynamic>.from(fila as Map))
        .toList();
  }

  static String _clave(Map<String, dynamic> fila) =>
      fila['cveInscripcion'].toString();

  Future<void> _cargarCatalogos() async {
    final cliente = Supabase.instance.client;
    if (cliente.auth.currentUser == null) {
      throw StateError('Inicia sesión como profesor para continuar');
    }

    final resultados = await Future.wait<dynamic>([
      cliente.rpc('soga_docente_grupos'),
      cliente.rpc('soga_docente_alumnos'),
    ]);
    if (!mounted) return;
    setState(() {
      _relaciones = _convertirFilas(resultados[0]);
      _alumnos = _convertirFilas(resultados[1]);
      if (!_relaciones.any((r) => _clave(r) == _relacionSeleccionada)) {
        _relacionSeleccionada = null;
        _matriculaSeleccionada = null;
      }
    });
  }

  void _recargar() {
    setState(() => _carga = _cargarCatalogos());
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final motivo = _motivoController.text.trim();
    final relacion = _relaciones.where(
      (r) => _clave(r) == _relacionSeleccionada,
    );
    if (motivo.isEmpty ||
        motivo.length > 150 ||
        relacion.isEmpty ||
        _matriculaSeleccionada == null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa todos los campos (motivo máximo 150 caracteres)',
          ),
        ),
      );
      return;
    }

    final fecha = _fechaSeleccionada!;
    final hora = _horaSeleccionada!;
    final fechaHora = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );
    if (fechaHora.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha y hora deben ser actuales o futuras'),
        ),
      );
      return;
    }

    final idMateria = (relacion.first['idMateria'] as num).toInt();
    String dos(int n) => n.toString().padLeft(2, '0');
    setState(() => _guardando = true);
    try {
      await Supabase.instance.client.rpc(
        'soga_docente_registrar_asesoria',
        params: {
          'p_matricula': _matriculaSeleccionada,
          'p_id_materia': idMateria,
          'p_titulo': motivo,
          'p_fecha': '${fecha.year}-${dos(fecha.month)}-${dos(fecha.day)}',
          'p_hora': '${dos(hora.hour)}:${dos(hora.minute)}:00',
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asesoría registrada correctamente')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar la asesoría: $error')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profesor =
        DatosTemporales.sesionActual?.nombre ?? 'Profesor autenticado';
    final disponibles = _alumnos
        .where((alumno) => _clave(alumno) == _relacionSeleccionada)
        .toList();
    final alumnosUnicos = <String, String>{};
    for (final alumno in disponibles) {
      final matricula = alumno['matricula']?.toString();
      if (matricula != null) {
        alumnosUnicos[matricula] = alumno['nombre']?.toString() ?? 'Alumno';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      appBar: AppBar(
        title: const Text('Registrar asesoría'),
        backgroundColor: const Color(0xFF7043FF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const EncabezadoSoga(
            titulo: 'Generar asesoría',
            accion: 'Registra una nueva asesoría',
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _carga,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No se pudieron cargar las relaciones: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _recargar,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const Text(
                      'Información de la asesoría',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profesor: $profesor',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextField(
                              controller: _motivoController,
                              maxLength: 150,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Motivo de la asesoría',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              key: ValueKey('relacion-$_relacionSeleccionada'),
                              initialValue: _relacionSeleccionada,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Grupo y materia',
                                prefixIcon: Icon(
                                  Icons.menu_book,
                                  color: Color(0xFF7043FF),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              items: _relaciones
                                  .map(
                                    (fila) => DropdownMenuItem<String>(
                                      value: _clave(fila),
                                      child: Text(
                                        '${fila['nombreGrupo']} · ${fila['materia']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _relaciones.isEmpty
                                  ? null
                                  : (valor) {
                                      setState(() {
                                        _relacionSeleccionada = valor;
                                        _matriculaSeleccionada = null;
                                      });
                                    },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              key: ValueKey(
                                'alumno-$_relacionSeleccionada-$_matriculaSeleccionada',
                              ),
                              initialValue: _matriculaSeleccionada,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Alumno',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Color(0xFF7043FF),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              items: alumnosUnicos.entries
                                  .map(
                                    (entrada) => DropdownMenuItem<String>(
                                      value: entrada.key,
                                      child: Text(
                                        entrada.value,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _relacionSeleccionada == null
                                  ? null
                                  : (valor) => setState(
                                      () => _matriculaSeleccionada = valor,
                                    ),
                            ),
                            if (_relacionSeleccionada != null &&
                                alumnosUnicos.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'No hay alumnos inscritos en esta materia.',
                                ),
                              ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _fechaSeleccionada == null
                                          ? 'Fecha'
                                          : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                                    ),
                                    onPressed: () async {
                                      final ahora = DateTime.now();
                                      final hoy = DateTime(
                                        ahora.year,
                                        ahora.month,
                                        ahora.day,
                                      );
                                      final inicial =
                                          _fechaSeleccionada != null &&
                                              !_fechaSeleccionada!.isBefore(hoy)
                                          ? _fechaSeleccionada!
                                          : hoy;
                                      final elegida = await showDatePicker(
                                        context: context,
                                        initialDate: inicial,
                                        firstDate: hoy,
                                        lastDate: DateTime(
                                          hoy.year + 5,
                                          12,
                                          31,
                                        ),
                                      );
                                      if (elegida != null && mounted) {
                                        setState(
                                          () => _fechaSeleccionada = elegida,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _horaSeleccionada?.format(context) ??
                                          'Hora',
                                    ),
                                    onPressed: () async {
                                      final elegida = await showTimePicker(
                                        context: context,
                                        initialTime:
                                            _horaSeleccionada ??
                                            TimeOfDay.now(),
                                      );
                                      if (elegida != null && mounted) {
                                        setState(
                                          () => _horaSeleccionada = elegida,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          _guardando ? 'Guardando...' : 'Guardar asesoría',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7140FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    if (_relaciones.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Aún no tienes grupos y materias asignados.',
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
