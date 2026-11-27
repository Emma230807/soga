import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/views/agregar_docentes.dart';
import 'package:soga/views/agregar_inscripcion.dart';
import 'package:soga/views/agregar_materia.dart';
import 'package:soga/views/altaGrupo.dart';
import 'package:soga/views/perfil.dart';
import 'package:soga/views/carga_administradores.dart';

import 'pantalla_login.dart';

class HomeAdministrador extends StatefulWidget {
  final UsuarioSesion usuario;

  const HomeAdministrador({super.key, required this.usuario});

  @override
  State<HomeAdministrador> createState() => _HomeAdministradorState();
}

class _HomeAdministradorState extends State<HomeAdministrador> {
  // ABRIR PERFIL
  void abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPerfil(usuario: widget.usuario),
      ),
    );
  }

  // CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    try {
      await DatosTemporales.cerrarSesionSupabase();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al cerrar sesión')));
    }
  }

  // AGREGAR DOCENTE
  void abrirPantallaDocente() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaAgregarDocente()),
    );

  }

  // AGREGAR GRUPO
  void abrirPantallaFormularioGrupo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AltaGrupo()),
    );
  }

  // AGREGAR MATERIA
  void abrirPantallaFormularioMteria() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaAgregarMateria()),
    );
  }

  // AGREGAR INSCRIPCIÓN
  void abrirPantallaFormularioInscripcion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaAgregarInscripcion()),
    );
  }

  void abrirCargaAdministradores() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CargaAdministradores()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      body: Column(
        children: [
          // ENCABEZADO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 25),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PANEL ADMINISTRADOR',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      IconButton(
                        onPressed: cerrarSesion,
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Administración',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Panel de administración',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Gestiona docentes, grupos, materias e inscripciones.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // CONTENIDO
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // NOMBRE DEL ADMINISTRADOR Y ACCESO A PERFIL
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.usuario.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF39275C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: abrirPerfil,
                      icon: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.deepPurple,
                      ),
                      label: const Text(
                        'Mi perfil',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR DOCENTE
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: abrirPantallaDocente,

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar docente'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR GRUPO
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: abrirPantallaFormularioGrupo,

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar grupo'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR MATERIA
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: abrirPantallaFormularioMteria,

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar materia'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR INSCRIPCIÓN
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: abrirPantallaFormularioInscripcion,

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar inscripcion'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR Inscripcion
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      abrirCargaAdministradores();
                    },

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar administrador'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // LOGO DE SOGA SIN FONDO, EN COLOR MORADO
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.code,
                        size: 90,
                        color: Color(0xFF7043FF),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'S O G A',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Color(0xFF7043FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
