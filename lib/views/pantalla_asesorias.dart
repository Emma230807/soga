import 'package:flutter/material.dart';
import 'package:soga/datasourses/datos_temporales.dart';

/// Lista de asesorías del alumno autenticado en Supabase.
class PantallaAsesorias extends StatefulWidget {
  const PantallaAsesorias({super.key});

  @override
  State<PantallaAsesorias> createState() => _PantallaAsesoriasState();
}

class _PantallaAsesoriasState extends State<PantallaAsesorias> {
  late Future<_DatosAsesorias> _consulta;

  @override
  void initState() {
    super.initState();
    _consulta = _cargar();
  }

  Future<_DatosAsesorias> _cargar() async {
    final filas = await DatosTemporales.obtenerAsesoriasSupabase();
    // El catálogo sirve para mostrar el nombre, nunca el idMateria.
    final materias = await DatosTemporales.obtenerMateriasAsesoriaSupabase();
    return _DatosAsesorias(
      filas: filas,
      materias: {
        for (final materia in materias)
          (materia['idMateria'] as num).toInt():
              (materia['nombre'] as String? ?? 'Sin nombre'),
      },
    );
  }

  void _actualizar() {
    setState(() => _consulta = _cargar());
  }

  Future<void> _recargar() async {
    _actualizar();
    try {
      await _consulta;
    } catch (_) {
      // El error se muestra en FutureBuilder.
    }
  }

  String _fecha(dynamic valor) {
    if (valor == null) return 'Sin fecha';
    final fecha = DateTime.tryParse(valor.toString());
    if (fecha == null) return valor.toString();
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _hora(dynamic valor) {
    if (valor == null) return 'Sin hora';
    final texto = valor.toString();
    return texto.length >= 5 ? texto.substring(0, 5) : texto;
  }

  Widget _tarjeta(Map<String, dynamic> asesoria, Map<int, String> materias) {
    final motivo = (asesoria['titulo'] as String?)?.trim();
    final nombreProfesor = (asesoria['nombreCompletoProfesor'] as String?)
        ?.trim();
    final idMateria = (asesoria['idMateria'] as num?)?.toInt();
    final nombreMateria = idMateria == null
        ? 'Materia no especificada'
        : (materias[idMateria] ?? 'Materia no disponible');
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x307043FF),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: Color(0xFF7043FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motivo == null || motivo.isEmpty
                            ? 'Asesoría académica'
                            : motivo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF30254B),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        nombreMateria,
                        style: const TextStyle(color: Color(0xFF7043FF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _dato(
              Icons.person_outline,
              'Profesor',
              nombreProfesor == null || nombreProfesor.isEmpty
                  ? 'No especificado'
                  : nombreProfesor,
            ),
            const SizedBox(height: 10),
            _dato(
              Icons.calendar_today_outlined,
              'Fecha',
              _fecha(asesoria['fecha']),
            ),
            const SizedBox(height: 10),
            _dato(Icons.access_time_outlined, 'Hora', _hora(asesoria['hora'])),
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String etiqueta, String valor) {
    return Row(
      children: [
        Icon(icono, size: 19, color: const Color(0xFF7043FF)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$etiqueta: $valor',
            style: const TextStyle(color: Color(0xFF514A60)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7043FF),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Mis asesorías',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 27,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'MI ESPACIO ESCOLAR',
                          style: TextStyle(
                            color: Colors.white70,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Organiza, Aprende y Avanza',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Consulta tus asesorías solicitadas.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<_DatosAsesorias>(
              future: _consulta,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFF7043FF),
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No se pudieron cargar las asesorías: '
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _actualizar,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final datos = snapshot.data!;
                if (datos.filas.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_note_outlined,
                              color: Color(0xFF9279C8),
                              size: 56,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Todavía no has solicitado asesorías',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _tarjeta(datos.filas[index], datos.materias),
                      childCount: datos.filas.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DatosAsesorias {
  final List<Map<String, dynamic>> filas;
  final Map<int, String> materias;

  const _DatosAsesorias({required this.filas, required this.materias});
}
