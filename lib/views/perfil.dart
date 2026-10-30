
import 'package:flutter/material.dart';
import 'package:soga/models/usuario_sesion.dart';
import 'package:soga/datasourses/datos_temporales.dart';

class PantallaPerfil extends StatelessWidget {
  final UsuarioSesion usuario;

  const PantallaPerfil({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {

    String rol = "";
    String identificador = "";
    String etiquetaIdentificador = "ID de usuario";

    // Identificar el tipo de usuario
    switch (usuario.rol) {
      case RolUsuario.alumno:
        rol = "Alumno";
        etiquetaIdentificador = "Código de alumno";
        identificador =
            DatosTemporales.obtenerCodigoAlumno(usuario.correo)
                ?? "No asignado";
        break;

      case RolUsuario.docente:
        rol = "Docente";
        identificador = usuario.id.toString();
        break;

      case RolUsuario.administrador:
        rol = "Administrador";
        identificador = usuario.id.toString();
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Mi perfil",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ENCABEZADO
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
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    usuario.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    rol,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "INFORMACIÓN PERSONAL",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  datoPerfil(
                    Icons.person_outline,
                    "Nombre completo",
                    usuario.nombre,
                  ),

                  datoPerfil(
                    Icons.email_outlined,
                    "Correo electrónico",
                    usuario.correo,
                  ),

                  datoPerfil(
                    Icons.badge_outlined,
                    etiquetaIdentificador,
                    identificador,
                  ),

                  datoPerfil(
                    Icons.school_outlined,
                    "Tipo de usuario",
                    rol,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget datoPerfil(
    IconData icono,
    String etiqueta,
    String valor,
  ) {
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
            child: Icon(
              icono,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
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
}
