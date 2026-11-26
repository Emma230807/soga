import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class PruebaSupabase {
  static Future<void> probarAlumno({
    required String correo,
    required String contrasena,
  }) async {
    final supabase = Supabase.instance.client;

    // 1. Iniciar sesión con Supabase Auth
    final respuesta = await supabase.auth.signInWithPassword(
      email: correo.trim(),
      password: contrasena,
    );

    final usuarioAuth = respuesta.user;

    if (usuarioAuth == null) {
      throw Exception('No se pudo iniciar sesión');
    }

    // 2. Recuperar el perfil del usuario
    final perfil = await supabase
        .from('usuario')
        .select('idUsuario, nombreCompleto, tipoUsuario')
        .eq('auth_uid', usuarioAuth.id)
        .single();

    // 3. Recuperar la matrícula del alumno
    final alumno = await supabase
        .from('alumno')
        .select('matricula')
        .eq('idUsuario', perfil['idUsuario'])
        .single();

    // 4. Mostrar los datos recuperados
    debugPrint('Conexión con Supabase exitosa');
    debugPrint('Nombre: ${perfil['nombreCompleto']}');
    debugPrint('Rol: ${perfil['tipoUsuario']}');
    debugPrint('Matrícula: ${alumno['matricula']}');
  }
}

class PantallaPruebaSupabase extends StatefulWidget {
  const PantallaPruebaSupabase({super.key});

  @override
  State<PantallaPruebaSupabase> createState() => _PantallaPruebaSupabaseState();
}

class _PantallaPruebaSupabaseState extends State<PantallaPruebaSupabase> {
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();

  bool cargando = false;
  String mensaje = '';

  Future<void> iniciarPrueba() async {
    setState(() {
      cargando = true;
      mensaje = 'Conectando con Supabase...';
    });

    try {
      await PruebaSupabase.probarAlumno(
        correo: correoController.text.trim(),
        contrasena: contrasenaController.text,
      );

      if (!mounted) return;

      setState(() {
        mensaje = 'Autenticación y consulta exitosas';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensaje = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Supabase - SOGA')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            TextField(
              controller: contrasenaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: cargando ? null : iniciarPrueba,
              child: Text(cargando ? 'Conectando...' : 'Probar conexión'),
            ),
            const SizedBox(height: 20),
            Text(mensaje),
          ],
        ),
      ),
    );
  }
}
