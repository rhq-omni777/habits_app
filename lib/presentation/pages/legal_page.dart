import 'package:flutter/material.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad y términos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Principios de protección de datos', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          _Bullet('Minimización: solo se almacenan email y nombre para la cuenta y los datos de hábitos/progreso.'),
          _Bullet('Control del usuario: puedes cerrar sesión y dejar de registrar hábitos en cualquier momento.'),
          _Bullet('Uso declarado: los datos se emplean únicamente para seguimiento personal de hábitos.'),
          _Bullet('Seguridad: el tráfico usa HTTPS (Firebase). Se recomiendan reglas por usuario en Firestore.'),
          const SizedBox(height: 16),
          Text('Derechos del usuario (referencia Ecuador)', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _Bullet('Derecho a la salud (Constitución Art. 32) y a la protección de datos personales (Art. 66).'),
          _Bullet('Autodeterminación informativa (LOPDP 2021): decisión y control sobre tus datos.'),
          const SizedBox(height: 16),
          Text('Buenas prácticas sugeridas', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _Bullet('Configura contraseñas robustas y activa bloqueo de pantalla del dispositivo.'),
          _Bullet('Gestiona notificaciones: desactiva recordatorios que no necesites para evitar fatiga.'),
          _Bullet('Si compartes el dispositivo, evita exponer información sensible en pantalla abierta.'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Esta aplicación está orientada al bienestar y no reemplaza consejo médico. Para síntomas o condiciones de salud, consulta a un profesional.',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
