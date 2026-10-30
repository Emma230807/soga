import 'package:flutter/material.dart';
import 'package:soga/views/agregar_docentes.dart';
import 'package:soga/views/agregar_inscripcion.dart';
import 'package:soga/views/agregar_materia.dart';
import 'package:soga/views/altaGrupo.dart';

import '../datasourses/datos_temporales.dart';
import 'pantalla_login.dart';

class HomeAdministrador extends StatefulWidget {
  const HomeAdministrador({super.key});

  @override
  State<HomeAdministrador> createState() => _HomeAdministradorState();
}

class _HomeAdministradorState extends State<HomeAdministrador> {
  void cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  void abrirPantallaDocente() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaAgregarDocente()),
    );
  }

  void abrirPantallaFormularioGrupo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AltaGrupo()),
    );
  }

  void abrirPantallaFormularioMteria() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaAgregarMateria()),
    );
  }

  void abrirPantallaFormularioInscripcion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaAgregarInscripcion()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docentes = DatosTemporales.docentes;

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
                    'Administración de docentes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Consulta y administra los docentes del sistema.',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Docentes registrados',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${docentes.length}',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF7043FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // LISTA DE DOCENTES
                if (docentes.isEmpty)
                  const Center(child: Text('No hay docentes registrados'))
                else
                  ...docentes.map(
                    (docente) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF7043FF),
                          child: Icon(Icons.person, color: Colors.white),
                        ),

                        title: Text(
                          docente.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(docente.correo),

                        trailing: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Falta conectar la edición de docentes',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF7043FF),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR DOCENTE
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      abrirPantallaDocente();
                    },

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar docente'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR Grupo
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      abrirPantallaFormularioGrupo();
                    },

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar grupo'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÓN AGREGAR Materia
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      abrirPantallaFormularioMteria();
                    },

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar materia'),

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
                      abrirPantallaFormularioInscripcion();
                    },

                    icon: const Icon(Icons.add),

                    label: const Text('Agregar inscripcion'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7043FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
