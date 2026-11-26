import 'package:flutter/material.dart';
import 'package:soga/models/tarea.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaDetalleTarea extends StatelessWidget {
  final Tarea tarea;

  const PantallaDetalleTarea({
    super.key,
    required this.tarea,
  });

  static const Color _moradoSoga = Color(0xFF7043FF);

  Color _colorDeTarea(String valor) {
    final nombre = valor.trim().toLowerCase();
    const colores = <String, Color>{
      'morado': Color(0xFF7043FF),
      'violeta': Color(0xFF7043FF),
      'purple': Color(0xFF7043FF),
      'azul': Color(0xFF3887F6),
      'blue': Color(0xFF3887F6),
      'verde': Color(0xFF26A879),
      'green': Color(0xFF26A879),
      'naranja': Color(0xFFFF9645),
      'orange': Color(0xFFFF9645),
      'amarillo': Color(0xFFFFCB40),
      'yellow': Color(0xFFFFCB40),
      'rojo': Color(0xFFEF5B64),
      'red': Color(0xFFEF5B64),
      'rosa': Color(0xFFED73AB),
      'pink': Color(0xFFED73AB),
    };
    if (colores.containsKey(nombre)) return colores[nombre]!;

    // También admite colores guardados como #RRGGBB o 0xAARRGGBB.
    final limpio = nombre.replaceFirst('#', '').replaceFirst('0x', '');
    if (RegExp(r'^[0-9a-f]{6}$').hasMatch(limpio)) {
      return Color(int.parse('FF$limpio', radix: 16));
    }
    if (RegExp(r'^[0-9a-f]{8}$').hasMatch(limpio)) {
      return Color(int.parse(limpio, radix: 16));
    }
    return _moradoSoga;
  }

  String _fechaLegible(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  Widget _dato({
    required IconData icono,
    required String etiqueta,
    required String valor,
    required Color acento,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: acento, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(fontSize: 12, color: Color(0xFF656073)),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF242037),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final acento = _colorDeTarea(tarea.color);
    final fondoTarjeta = Color.alphaBlend(
      acento.withValues(alpha: 0.14),
      Colors.white,
    );
    final descripcion = tarea.descripcion.trim();
    final pendiente = !tarea.completada;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text(
          'Detalle de tarea',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _moradoSoga,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(7),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 74),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7043FF), Color(0xFFA16BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MI ESPACIO ESCOLAR',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Organiza, Aprende y Avanza',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Consulta los detalles de tu actividad',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: fondoTarjeta,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: acento.withValues(alpha: 0.25),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF342A53).withValues(alpha: 0.09),
                        blurRadius: 22,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 9,
                            height: 36,
                            decoration: BoxDecoration(
                              color: acento,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tarea.titulo,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF242037),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: pendiente
                              ? Colors.white.withValues(alpha: 0.85)
                              : const Color(0xFFDCF5E7),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pendiente ? Icons.schedule : Icons.check_circle,
                              size: 17,
                              color: pendiente
                                  ? const Color(0xFF7950CC)
                                  : const Color(0xFF1D9062),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pendiente ? 'Pendiente' : 'Completada',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'DESCRIPCIÓN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Color(0xFF625B76),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        descripcion.isEmpty
                            ? 'Esta tarea no tiene descripción.'
                            : descripcion,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: Color(0xFF302A43),
                        ),
                      ),
                      const SizedBox(height: 23),
                      Divider(color: acento.withValues(alpha: 0.20)),
                      const SizedBox(height: 18),
                      _dato(
                        icono: Icons.calendar_month_outlined,
                        etiqueta: 'Fecha de entrega',
                        valor: _fechaLegible(tarea.fecha),
                        acento: acento,
                      ),
                      const SizedBox(height: 20),
                      _dato(
                        icono: Icons.flag_outlined,
                        etiqueta: 'Prioridad',
                        valor: tarea.prioridad.toUpperCase(),
                        acento: acento,
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: Supabase.instance.client
                            .from('materia')
                            .select('nombre')
                            .eq('idMateria', tarea.idMateria)
                            .maybeSingle(),
                        builder: (context, snapshot) {
                          final String nombreMateria;
                          if (snapshot.connectionState != ConnectionState.done) {
                            nombreMateria = 'Cargando materia...';
                          } else if (snapshot.hasError) {
                            nombreMateria = 'No se pudo cargar la materia';
                          } else {
                            nombreMateria = snapshot.data?['nombre'] as String?
                                ?? 'Materia no encontrada';
                          }
                          return _dato(
                            icono: Icons.school_outlined,
                            etiqueta: 'Materia',
                            valor: nombreMateria,
                            acento: acento,
                          );
                        },
                      ),
                      if (tarea.matricula.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _dato(
                          icono: Icons.badge_outlined,
                          etiqueta: 'Matrícula',
                          valor: tarea.matricula,
                          acento: acento,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
