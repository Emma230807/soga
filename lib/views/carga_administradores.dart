import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CargaAdministradores extends StatefulWidget {
  const CargaAdministradores({super.key});

  @override
  State<CargaAdministradores> createState() => _CargaAdministradoresState();
}

class _CargaAdministradoresState extends State<CargaAdministradores> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _numero = TextEditingController();
  final _usuario = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _mostrarContrasena = false;
  bool _guardando = false;
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _administradores = [];

  SupabaseClient get _cliente => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _numero.dispose();
    _usuario.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final respuesta = await _cliente.rpc('soga_admin_listar_administradores');
      if (respuesta is! List) {
        throw const FormatException('La consulta no devolvió una lista');
      }
      if (!mounted) return;
      setState(() {
        _administradores = respuesta
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar los administradores: $e';
      });
    }
  }

  String? _validarObligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardar() async {
    if (_guardando || !_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final respuesta = await _cliente.functions.invoke(
        'soga-admin-administradores',
        body: {
          'accion': 'crear',
          'nombre': _nombre.text.trim(),
          'numeroEmpleado': _numero.text.trim(),
          'usuario': _usuario.text.trim(),
          'correo': _correo.text.trim().toLowerCase(),
          'contrasena': _contrasena.text,
        },
      );
      if (respuesta.status < 200 || respuesta.status >= 300) {
        throw StateError(_mensajeError(respuesta.data));
      }
      if (!mounted) return;
      _nombre.clear();
      _numero.clear();
      _usuario.clear();
      _correo.clear();
      _contrasena.clear();
      _aviso('Administrador registrado correctamente');
      await _cargar();
    } on FunctionException catch (e) {
      _aviso('No se pudo guardar: ${_mensajeError(e.details)}');
    } catch (e) {
      _aviso('No se pudo guardar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _mensajeError(dynamic dato) {
    if (dato is Map) {
      return (dato['error'] ?? dato['mensaje'] ?? dato['message'] ?? dato)
          .toString();
    }
    return dato?.toString() ?? 'Error desconocido';
  }

  Future<void> _eliminar(Map<String, dynamic> administrador) async {
    final id = (administrador['idUsuario'] as num).toInt();
    final nombre = (administrador['nombre'] ?? 'este administrador').toString();
    final actual = administrador['esActual'] == true;
    if (actual) {
      _aviso('No puedes eliminar tu propia cuenta');
      return;
    }
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar administrador'),
        content: Text(
          '¿Quieres eliminar la cuenta de $nombre? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted || _guardando) return;
    setState(() => _guardando = true);
    try {
      final respuesta = await _cliente.functions.invoke(
        'soga-admin-administradores',
        body: {'accion': 'eliminar', 'idUsuario': id},
      );
      if (respuesta.status < 200 || respuesta.status >= 300) {
        throw StateError(_mensajeError(respuesta.data));
      }
      _aviso('Administrador eliminado correctamente');
      await _cargar();
    } on FunctionException catch (e) {
      _aviso('No se pudo eliminar: ${_mensajeError(e.details)}');
    } catch (e) {
      _aviso('No se pudo eliminar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _campo(
    String titulo,
    TextEditingController controlador,
    IconData icono, {
    TextInputType teclado = TextInputType.text,
    bool esContrasena = false,
    String? ejemplo,
    String? Function(String?)? validar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controlador,
          keyboardType: teclado,
          enabled: !_guardando,
          obscureText: esContrasena && !_mostrarContrasena,
          validator: validar ?? _validarObligatorio,
          decoration: InputDecoration(
            hintText: ejemplo,
            prefixIcon: Icon(icono, color: Colors.deepPurple),
            suffixIcon: esContrasena
                ? IconButton(
                    onPressed: () => setState(
                      () => _mostrarContrasena = !_mostrarContrasena,
                    ),
                    icon: Icon(
                      _mostrarContrasena
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _cargar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 25),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF824DFF), Color(0xFFA56AFF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'PANEL ADMINISTRADOR',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Agregar administradores',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Registra un nuevo administrador en el sistema.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información del administrador',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _campo(
                                'Nombre completo',
                                _nombre,
                                Icons.person_outline,
                                ejemplo: 'Ej. Miguel García',
                              ),
                              const SizedBox(height: 20),
                              _campo(
                                'Número de empleado',
                                _numero,
                                Icons.numbers,
                                ejemplo: 'Ej. 1006',
                              ),
                              const SizedBox(height: 20),
                              _campo(
                                'Usuario',
                                _usuario,
                                Icons.account_circle_outlined,
                                ejemplo: 'Ej. MiguelR',
                              ),
                              const SizedBox(height: 20),
                              _campo(
                                'Correo electrónico',
                                _correo,
                                Icons.email_outlined,
                                teclado: TextInputType.emailAddress,
                                ejemplo: 'administrador@correo.com',
                                validar: (v) {
                                  if (v == null ||
                                      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                          .hasMatch(v.trim())) {
                                    return 'Ingresa un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _campo(
                                'Contraseña',
                                _contrasena,
                                Icons.lock_outline,
                                esContrasena: true,
                                ejemplo: 'Mínimo 8 caracteres',
                                validar: (v) => v == null || v.length < 8
                                    ? 'Mínimo 8 caracteres'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardar,
                            icon: _guardando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: const Text('Guardar administrador'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7140FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Administradores registrados',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Actualizar',
                              onPressed: _cargando ? null : _cargar,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        if (_cargando)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          )
                        else if (_administradores.isEmpty)
                          const Text('No hay administradores registrados')
                        else
                          ..._administradores.map(
                            (admin) => Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFEDE4FF),
                                  child: Icon(
                                    Icons.admin_panel_settings_outlined,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                title: Text(
                                  (admin['nombre'] ?? '').toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${admin['numeroEmpleado'] ?? ''} · ${admin['correo'] ?? ''}'
                                  '${admin['esActual'] == true ? ' · Tu cuenta' : ''}',
                                ),
                                trailing: IconButton(
                                  tooltip: admin['esActual'] == true
                                      ? 'No puedes eliminarte'
                                      : 'Eliminar administrador',
                                  onPressed:
                                      _guardando || admin['esActual'] == true
                                      ? null
                                      : () => _eliminar(admin),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
