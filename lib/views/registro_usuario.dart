import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registro público del alumno, accesible desde el login de SOGA.
/// El perfil se crea en PostgreSQL mediante un trigger de auth.users.
/// No inscribe automáticamente al alumno a un grupo.
class PantallaRegistroAlumno extends StatefulWidget {
  const PantallaRegistroAlumno({super.key});

  @override
  State<PantallaRegistroAlumno> createState() => _PantallaRegistroAlumnoState();
}

class _PantallaRegistroAlumnoState extends State<PantallaRegistroAlumno> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _matricula = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmar = TextEditingController();
  bool _guardando = false;
  bool _mostrarClave = false;

  @override
  void dispose() {
    _nombre.dispose();
    _matricula.dispose();
    _correo.dispose();
    _clave.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_guardando || !_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final respuesta = await Supabase.instance.client.auth.signUp(
        email: _correo.text.trim().toLowerCase(),
        password: _clave.text,
        data: {
          'nombreCompleto': _nombre.text.trim(),
          'matricula': _matricula.text.trim(),
        },
      );
      if (respuesta.user == null) {
        throw const AuthException('No fue posible iniciar el registro.');
      }
      if (!mounted) return;
      final necesitaConfirmacion = respuesta.session == null;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            necesitaConfirmacion ? 'Revisa tu correo' : 'Registro completado',
          ),
          content: Text(
            necesitaConfirmacion
                ? 'Si el registro es válido, recibirás un enlace para confirmar tu correo. Después podrás iniciar sesión en SOGA.'
                : 'Tu cuenta de alumno fue creada. Ya puedes iniciar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      // Cuando la confirmación está desactivada, signUp abre la sesión automáticamente.
      // Cerramos esa sesión para regresar al login de manera consistente.
      if (respuesta.session != null) {
        await Supabase.instance.client.auth.signOut();
      }
      if (!mounted) return;
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo registrar: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    required String? Function(String?) validator,
    TextInputType? teclado,
    List<TextInputFormatter>? formatters,
    bool password = false,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !_guardando,
        keyboardType: teclado,
        inputFormatters: formatters,
        maxLength: maxLength,
        obscureText: password && !_mostrarClave,
        autocorrect: !password,
        enableSuggestions: !password,
        validator: validator,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono, color: Colors.deepPurple),
          counterText: '',
          suffixIcon: password
              ? IconButton(
                  tooltip: _mostrarClave
                      ? 'Ocultar contraseñas'
                      : 'Mostrar contraseñas',
                  onPressed: () =>
                      setState(() => _mostrarClave = !_mostrarClave),
                  icon: Icon(
                    _mostrarClave ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF824DFF), Color(0xFFA56AFF)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      tooltip: 'Regresar al login',
                      onPressed: _guardando
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SOGA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Regístrate como alumno y comienza a organizar tus actividades.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del alumno',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _campo(
                        controller: _nombre,
                        etiqueta: 'Nombre completo',
                        icono: Icons.person_outline,
                        validator: (v) => (v?.trim().length ?? 0) < 3
                            ? 'Ingresa tu nombre completo'
                            : null,
                      ),
                      _campo(
                        controller: _matricula,
                        etiqueta: 'Número de control',
                        icono: Icons.badge_outlined,
                        teclado: TextInputType.number,
                        maxLength: 10,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) => RegExp(r'^\d{10}$').hasMatch(v ?? '')
                            ? null
                            : 'Debe contener exactamente 10 dígitos',
                      ),
                      _campo(
                        controller: _correo,
                        etiqueta: 'Correo electrónico',
                        icono: Icons.email_outlined,
                        teclado: TextInputType.emailAddress,
                        validator: (v) =>
                            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(v?.trim() ?? '')
                            ? null
                            : 'Correo no válido',
                      ),
                      _campo(
                        controller: _clave,
                        etiqueta: 'Contraseña',
                        icono: Icons.lock_outline,
                        password: true,
                        validator: (v) => (v?.length ?? 0) >= 8
                            ? null
                            : 'Mínimo 8 caracteres',
                      ),
                      _campo(
                        controller: _confirmar,
                        etiqueta: 'Confirmar contraseña',
                        icono: Icons.lock_reset_outlined,
                        password: true,
                        validator: (v) => v == _clave.text
                            ? null
                            : 'Las contraseñas no coinciden',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _guardando ? null : _registrar,
                          icon: _guardando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1),
                          label: Text(
                            _guardando ? 'Registrando...' : 'Crear cuenta',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _guardando
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
    );
  }
}
