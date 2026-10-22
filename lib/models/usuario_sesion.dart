enum RolUsuario { alumno, docente, administrador }

class UsuarioSesion {
  final int id;
  final String nombre;
  final String correo;
  final RolUsuario rol;

  const UsuarioSesion({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });
}
