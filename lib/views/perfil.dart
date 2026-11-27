import 'package:flutter/material.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaPerfil extends StatefulWidget {
  final UsuarioSesion usuario;

  const PantallaPerfil({super.key, required this.usuario});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _anterior = TextEditingController();
  final _correoAdmin = TextEditingController();
  final _claveAdmin = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmacion = TextEditingController();

  bool _medianteAdministrador = false;
  bool _mostrarClaves = false;
  bool _guardando = false;

  @override
  void dispose() {
    _anterior.dispose();
    _correoAdmin.dispose();
    _claveAdmin.dispose();
    _nueva.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  String get _rol {
    switch (widget.usuario.rol) {
      case RolUsuario.alumno:
        return 'Alumno';
      case RolUsuario.docente:
        return 'Docente';
      case RolUsuario.administrador:
        return 'Administrador';
    }
  }

  String get _etiquetaIdentificador => widget.usuario.rol == RolUsuario.alumno
      ? 'Matrícula'
      : 'Número de empleado';

  String get _identificador {
    switch (widget.usuario.rol) {
      case RolUsuario.alumno:
        return widget.usuario.matricula ?? 'No asignado';
      case RolUsuario.docente:
        return widget.usuario.numeroEmpleadoProf ?? 'No asignado';
      case RolUsuario.administrador:
        return widget.usuario.numeroEmpleadoAdmin ?? 'No asignado';
    }
  }

  Future<void> _cambiarContrasena() async {
    if (_guardando || !_formKey.currentState!.validate()) return;
    final cliente = Supabase.instance.client;
    final token = cliente.auth.currentSession?.accessToken;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión expiró. Inicia sesión otra vez.'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final respuesta = await cliente.functions.invoke(
        'soga-cambiar-contrasena',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'metodo': _medianteAdministrador ? 'administrador' : 'propia',
          'contrasenaAnterior': _medianteAdministrador ? null : _anterior.text,
          'correoAdministrador': _medianteAdministrador
              ? _correoAdmin.text.trim()
              : null,
          'contrasenaAdministrador': _medianteAdministrador
              ? _claveAdmin.text
              : null,
          'contrasenaNueva': _nueva.text,
        },
      );

      final datos = respuesta.data;
      if (respuesta.status != 200 || datos is! Map || datos['ok'] != true) {
        throw Exception(
          datos is Map
              ? (datos['error'] ?? 'No fue posible cambiar la contraseña')
              : 'No fue posible cambiar la contraseña',
        );
      }

      _anterior.clear();
      _correoAdmin.clear();
      _claveAdmin.clear();
      _nueva.clear();
      _confirmacion.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la contraseña: $error')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) =>
      InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _campoClave(
    TextEditingController controlador,
    String etiqueta, {
    String? Function(String?)? validador,
  }) {
    return TextFormField(
      controller: controlador,
      obscureText: !_mostrarClaves,
      autocorrect: false,
      enableSuggestions: false,
      decoration: _decoracion(etiqueta, Icons.lock_outline),
      validator:
          validador ??
          (valor) => (valor == null || valor.isEmpty)
              ? 'Este campo es obligatorio'
              : null,
    );
  }

  Widget _datoPerfil(IconData icono, String etiqueta, String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFECE9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: Colors.deepPurple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('SOGA | Mi perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.usuario.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _rol,
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INFORMACIÓN PERSONAL',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _datoPerfil(
                    Icons.person_outline,
                    'Nombre completo',
                    widget.usuario.nombre,
                  ),
                  _datoPerfil(
                    Icons.email_outlined,
                    'Correo electrónico',
                    widget.usuario.correo,
                  ),
                  _datoPerfil(
                    Icons.badge_outlined,
                    _etiquetaIdentificador,
                    _identificador,
                  ),
                  _datoPerfil(Icons.school_outlined, 'Tipo de usuario', _rol),
                  const SizedBox(height: 16),
                  const Text(
                    'SEGURIDAD DE LA CUENTA',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cambiar contraseña',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Método de autorización'),
                          const SizedBox(height: 8),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Contraseña anterior'),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Administrador'),
                              ),
                            ],
                            selected: {_medianteAdministrador},
                            onSelectionChanged: _guardando
                                ? null
                                : (seleccion) {
                                    setState(() {
                                      _medianteAdministrador = seleccion.first;
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                          if (_medianteAdministrador) ...[
                            const Text(
                              'El administrador debe ingresar sus propias '
                              'credenciales para autorizar el cambio.',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _correoAdmin,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration: _decoracion(
                                'Correo del administrador',
                                Icons.email_outlined,
                              ),
                              validator: (valor) {
                                if (!_medianteAdministrador) return null;
                                if (valor == null || !valor.contains('@')) {
                                  return 'Ingresa el correo del administrador';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _campoClave(
                              _claveAdmin,
                              'Contraseña del administrador',
                            ),
                          ] else ...[
                            _campoClave(_anterior, 'Contraseña actual'),
                          ],
                          const SizedBox(height: 12),
                          _campoClave(
                            _nueva,
                            'Nueva contraseña',
                            validador: (valor) {
                              if (valor == null || valor.length < 8) {
                                return 'Utiliza al menos 8 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _campoClave(
                            _confirmacion,
                            'Confirmar nueva contraseña',
                            validador: (valor) {
                              if (valor != _nueva.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              if (valor == null || valor.isEmpty) {
                                return 'Confirma tu contraseña';
                              }
                              return null;
                            },
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _mostrarClaves,
                            onChanged: (valor) =>
                                setState(() => _mostrarClaves = valor ?? false),
                            title: const Text('Mostrar contraseñas'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _guardando ? null : _cambiarContrasena,
                              icon: _guardando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.lock_reset),
                              label: Text(
                                _guardando
                                    ? 'Guardando...'
                                    : 'Actualizar contraseña',
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
          ],
        ),
      ),
    );
  }
}
