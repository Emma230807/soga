import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/widgets/selector_fecha.dart';
import 'package:soga/widgets/selector_hora.dart';

class WidgetAsesoria extends StatefulWidget {
  const WidgetAsesoria({super.key});

  @override
  State<WidgetAsesoria> createState() => _WidgetAsesoriaState();
}

class _WidgetAsesoriaState extends State<WidgetAsesoria> {
  final TextEditingController _motivoController = TextEditingController();
  List<Map<String, dynamic>> _materias = [];
  List<Map<String, dynamic>> _profesores = [];
  int? _idMateria;
  String? _numeroEmpleadoProf;
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _cargandoMaterias = true;
  bool _cargandoProfesores = false;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  Future<void> _cargarMaterias() async {
    try {
      final datos = await DatosTemporales.obtenerMateriasAsesoriaSupabase();
      if (!mounted) return;
      setState(() {
        _materias = datos;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No fue posible cargar materias: $e');
    } finally {
      if (mounted) setState(() => _cargandoMaterias = false);
    }
  }

  Future<void> _seleccionarMateria(int? idMateria) async {
    setState(() {
      _idMateria = idMateria;
      _numeroEmpleadoProf = null;
      _profesores = [];
      _cargandoProfesores = idMateria != null;
      _error = null;
    });
    if (idMateria == null) return;
    try {
      final datos = await DatosTemporales.obtenerProfesoresMateriaSupabase(idMateria);
      if (!mounted || _idMateria != idMateria) return;
      setState(() => _profesores = datos);
    } catch (e) {
      if (!mounted || _idMateria != idMateria) return;
      setState(() => _error = 'No fue posible cargar profesores: $e');
    } finally {
      if (mounted && _idMateria == idMateria) {
        setState(() => _cargandoProfesores = false);
      }
    }
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final motivo = _motivoController.text.trim();
    if (motivo.isEmpty || motivo.length > 150 ||
        _idMateria == null || _numeroEmpleadoProf == null ||
        _fecha == null || _hora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa motivo, materia, profesor, fecha y hora (máx. 150 caracteres)')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await DatosTemporales.solicitarAsesoriaSupabase(
        motivo: motivo,
        idMateria: _idMateria!,
        numeroEmpleadoProf: _numeroEmpleadoProf!,
        fecha: _fecha!,
        hora: _hora!,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(content: Text('Asesoría solicitada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo solicitar la asesoría: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20,
              MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: Text('Agenda tu asesoría',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                  IconButton(
                    onPressed: _guardando ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF7043FF)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Motivo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _motivoController,
                maxLength: 150,
                maxLines: 2,
                decoration: InputDecoration(hintText: 'Motivo de tu asesoría', border: borde),
              ),
              const SizedBox(height: 12),
              const Text('Materia', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _idMateria,
                isExpanded: true,
                decoration: InputDecoration(border: borde,
                    hintText: _cargandoMaterias ? 'Cargando materias...' : 'Selecciona una materia'),
                items: _materias.map((m) => DropdownMenuItem<int>(
                  value: (m['idMateria'] as num).toInt(),
                  child: Text(m['nombre'] as String, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: _cargandoMaterias || _guardando ? null : _seleccionarMateria,
              ),
              const SizedBox(height: 16),
              const Text('Profesor', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_idMateria),
                value: _numeroEmpleadoProf,
                isExpanded: true,
                decoration: InputDecoration(border: borde, hintText:
                    _idMateria == null ? 'Primero selecciona una materia' :
                    _cargandoProfesores ? 'Cargando profesores...' :
                    _profesores.isEmpty ? 'No hay profesores asignados' : 'Selecciona un profesor'),
                items: _profesores.map((p) => DropdownMenuItem<String>(
                  value: p['numeroEmpleadoProf'] as String,
                  child: Text(p['nombreCompleto'] as String, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: _idMateria == null || _cargandoProfesores || _guardando || _profesores.isEmpty
                    ? null : (valor) => setState(() => _numeroEmpleadoProf = valor),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectorFecha(
                      fechaSeleccionada: _fecha,
                      onSeleccionar: (fecha) => setState(() => _fecha = fecha),
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectorHora(
                      horaSeleccionada: _hora,
                      onSeleccionar: (hora) => setState(() => _hora = hora),
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7043FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_guardando ? 'Guardando...' : 'Solicitar asesoría',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
