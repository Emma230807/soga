import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';

class PantallaPruebaFirebase extends StatefulWidget {
  const PantallaPruebaFirebase({super.key});

  @override
  State<PantallaPruebaFirebase> createState() => _PantallaPruebaFirebaseState();
}

class _PantallaPruebaFirebaseState extends State<PantallaPruebaFirebase> {
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();

  bool cargando = false;
  String mensaje = '';

  Future<void> ejecutarPrueba() async {
    setState(() {
      cargando = true;
      mensaje = 'Conectando con Firebase...';
    });

    try {
      await PruebaFirebase.probarConexion(
        correo: correoController.text.trim(),
        contrasena: contrasenaController.text,
      );

      await DatosTemporales.probarGuardadoTarea();

      if (!mounted) return;

      setState(() {
        mensaje = 'Conexión exitosa con Firestore';
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
      appBar: AppBar(title: const Text('Prueba Firebase - SOGA')),
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
              onPressed: cargando ? null : ejecutarPrueba,
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

class PruebaFirebase {
  static Future<void> probarConexion({
    required String correo,
    required String contrasena,
  }) async {
    // 1. Autenticar al usuario de prueba
    final credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo,
      password: contrasena,
    );

    final usuario = credencial.user;

    if (usuario == null) {
      throw Exception('No se pudo autenticar al usuario');
    }

    // 2. Guardar un documento en Firestore
    final documento = FirebaseFirestore.instance
        .collection('pruebas_conexion')
        .doc(usuario.uid);

    await documento.set({
      'mensaje': 'Conexión exitosa con SOGA',
      'fecha': FieldValue.serverTimestamp(),
      'estado': 'activo',
    });

    // 3. Recuperar el documento
    final resultado = await documento.get(
      const GetOptions(source: Source.server),
    );

    if (!resultado.exists) {
      throw Exception('No se encontró el documento');
    }

    print('Conexión exitosa');
    print('Datos recuperados: ${resultado.data()}');
  }
}
