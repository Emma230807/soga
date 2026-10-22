import 'package:soga/datasourses/tarea_data.dart';
import 'package:soga/models/tarea.dart';
import 'package:intl/intl.dart';

class CalendarioController {
  List<Tarea> tareas = TareasData.obtenerTareas();
  //convertir texto a fecha
  Map<DateTime, List<String>> obtenerTareasCalendario(){
    DateTime fecha;
    String fechaSin; 
     Map<DateTime,List<String>> tareasCalendario={}; 
     for(var tarea in tareas){
      if(tarea.completada != true){
        fechaSin=tarea.fechaEntrega; 
        fecha=DateFormat(
          'd MMM yyyy',
          'es_MX',
        ).parseStrict('$fechaSin ${DateTime.now().year}');
        tareasCalendario.putIfAbsent(fecha, () => []);
        tareasCalendario[fecha]!.add(tarea.titulo);
      }
     }
     return tareasCalendario; 
  }
  


}