import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soga/views/vista_splash.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (temporalmente)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://bwcrkvkpepwmpwjpimoe.supabase.co',
    publishableKey: 'sb_publishable_oHMPPSmBLFahhzdrnxE9OA_5tgqtRnV',
  );

  try {
    final resultado = await Supabase.instance.client
        .from('prueba_conexion')
        .select()
        .eq('id', 1)
        .single();

    debugPrint('Supabase: ${resultado['mensaje']}');
  } catch (e) {
    debugPrint('Error de conexión con Supabase: $e');
  }

  // Iniciar SOGA
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
