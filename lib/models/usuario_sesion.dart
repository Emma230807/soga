enum RolUsuario { alumno, docente, administrador }

class UsuarioSesion {
  final int id;
  final String nombre;
  final String correo;
  final RolUsuario rol;
  final String? matricula;
  final String? authUid;
  final String? numeroEmpleadoProf;

  const UsuarioSesion({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.matricula,
    this.authUid,
    this.numeroEmpleadoProf,
  });
}
