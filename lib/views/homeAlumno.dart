import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/tarea.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/views/pantalla_calendario.dart';
import 'package:soga/views/pantalla_login.dart';
import 'package:soga/views/pantalla_notas.dart';
import 'package:soga/views/pantalla_notificaciones.dart';
import 'package:soga/views/pantalla_tareas.dart';
import 'package:soga/views/perfil.dart';
import 'package:soga/widgets/formulario_nueva_tarea.dart';
import 'package:soga/widgets/tarjeta_acceso.dart';
import 'package:soga/widgets/tarjeta_tarea.dart';
import 'package:soga/widgets/widget_asesoria.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAlumno extends StatefulWidget {
  final UsuarioSesion usuario;

  const HomeAlumno({super.key, required this.usuario});

  @override
  State<HomeAlumno> createState() => _HomeAlumnoState();
}

class _HomeAlumnoState extends State<HomeAlumno> {
  List<Tarea> _tareas = [];
  bool _cargando = true;
  String? _error;
  final Set<int> _operacionesEnCurso = {};

  int get _completadas => _tareas.where((t) => t.completada).length;
  int get _pendientes => _tareas.length - _completadas;
  double get _progreso =>
      _tareas.isEmpty ? 0 : _completadas / _tareas.length;
  List<Tarea> get _tareasPendientes =>
      _tareas.where((t) => !t.completada).toList();

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Tarea _desdeSupabase(Map<String, dynamic> fila) {
    final fecha = DateTime.parse(fila['fecha'] as String);
    final valorPrioridad =
        (fila['prioridad'] as String? ?? 'MEDIA').toLowerCase();
    final prioridad = valorPrioridad.isEmpty
        ? 'Media'
        : '${valorPrioridad[0].toUpperCase()}${valorPrioridad.substring(1)}';

    return Tarea(
      idTarea: (fila['idTarea'] as num).toInt(),
      titulo: fila['titulo'] as String? ?? 'Sin título',
      descripcion: fila['descripcion'] as String? ?? '',
      prioridad: prioridad,
      fecha: fecha,
      idMateria: (fila['idMateria'] as num?)?.toInt() ?? 0,
      color: fila['color'] as String? ?? 'Morado',
      matricula: fila['matricula'] as String? ?? '',
      fechaEntrega: '${fecha.day}/${fecha.month}/${fecha.year}',
      completada: fila['completada'] as bool? ?? false,
      alumno: widget.usuario.nombre,
    );
  }

  Future<void> _cargarTareas() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final filas = await DatosTemporales.obtenerTareasSupabase();
      final tareas = filas.map(_desdeSupabase).toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
      if (!mounted) return;
      setState(() {
        _tareas = tareas;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No fue posible cargar las tareas: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _abrirPantallaTareas() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaTareas()),
    );
    if (mounted) await _cargarTareas();
  }

  Future<void> _mostrarFormularioTarea() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FormularioNuevaTarea(),
    );
    if (mounted) await _cargarTareas();
  }

  Future<void> _cambiarEstado(Tarea tarea) async {
    if (!_operacionesEnCurso.add(tarea.idTarea)) return;
    try {
      await DatosTemporales.cambiarEstadoTareaSupabase(
        tarea.idTarea,
        !tarea.completada,
      );
      await _cargarTareas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar la tarea: $e')),
        );
      }
    } finally {
      _operacionesEnCurso.remove(tarea.idTarea);
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    if (_operacionesEnCurso.contains(tarea.idTarea)) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text(
          '¿Quieres eliminar "${tarea.titulo}"? Esta acción no se puede deshacer.',
        ),
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
    if (!mounted || confirmado != true) return;
    if (!_operacionesEnCurso.add(tarea.idTarea)) return;
    try {
      await DatosTemporales.eliminarTareaSupabase(tarea.idTarea);
      await _cargarTareas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar la tarea: $e')),
        );
      }
    } finally {
      _operacionesEnCurso.remove(tarea.idTarea);
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo cerrar sesión: $e')),
        );
      }
    }
  }

  String get _fechaActual {
    const dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final hoy = DateTime.now();
    return '${dias[hoy.weekday - 1]}, ${hoy.day} de ${meses[hoy.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _cerrarSesion,
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar tareas',
            onPressed: _cargarTareas,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PantallaNotificaciones()),
            ),
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaPerfil(usuario: widget.usuario),
              ),
            ),
            icon: const Icon(Icons.account_circle, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarTareas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fechaActual,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hola, ${widget.usuario.nombre}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _cargando
                            ? 'Consultando tus tareas...'
                            : 'Tienes $_pendientes tareas pendientes',
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progreso',
                              style: TextStyle(color: Colors.white)),
                          Text(
                            '$_completadas/${_tareas.length} completadas',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progreso,
                          minHeight: 8,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'ACCESOS',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TarjetaAcceso(
                        titulo: 'Tareas',
                        subtitulo: '$_pendientes pendientes',
                        icono: Icons.check_box_outlined,
                        colorFondo: const Color(0xFFECE9FF),
                        colorIcono: Colors.deepPurple,
                        onTap: _abrirPantallaTareas,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TarjetaAcceso(
                        titulo: 'Notas',
                        subtitulo: 'Tus apuntes',
                        icono: Icons.description_outlined,
                        colorFondo: const Color(0xFFFFEBE5),
                        colorIcono: const Color(0xFFFF784F),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PantallaNotas()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TarjetaAcceso(
                        titulo: 'Calendario',
                        subtitulo: 'Ver fechas',
                        icono: Icons.calendar_month,
                        colorFondo: const Color(0xFFD5F8E9),
                        colorIcono: const Color(0xFF25C99B),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CalendarScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TarjetaAcceso(
                        titulo: 'Nueva tarea',
                        subtitulo: 'Agregar rápido',
                        icono: Icons.add,
                        colorFondo: const Color(0xFFFFF8C4),
                        colorIcono: const Color(0xFFFFB900),
                        onTap: _mostrarFormularioTarea,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TarjetaAcceso(
                        titulo: 'Agendar Asesoría',
                        subtitulo: 'Agenda una asesoría con tu docente',
                        icono: Icons.menu_book,
                        colorFondo: const Color(0xFFFFE5EA),
                        colorIcono: const Color(0xFFFF5C6C),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const WidgetAsesoria(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MIS TAREAS PENDIENTES',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar',
                      onPressed: _cargarTareas,
                      icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
              if (_cargando)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      TextButton(
                        onPressed: _cargarTareas,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else if (_tareasPendientes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No tienes tareas pendientes'),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (final tarea in _tareasPendientes)
                        TarjetaTarea(
                          tarea: tarea,
                          onCambiarEstado: () => _cambiarEstado(tarea),
                          onEliminar: () => _eliminarTarea(tarea),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
