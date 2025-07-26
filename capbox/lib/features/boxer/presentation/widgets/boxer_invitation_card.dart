import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoxerInvitationCard extends StatelessWidget {
  const BoxerInvitationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Campeonato estatal Conade',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Image.asset(
              'assets/images/event2.png',
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          _buildLabelValue('Lugar: ', 'Tuxtla Gutierrez'),
          _buildLabelValue('Fecha: ', '23 - 25 de febrero 2025'),
          _buildLabelValue('Costo total de asistencia: ', 'Gratuito'),
          const SizedBox(height: 8),
          const Text(
            'Información adicional:',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'El evento se llevará a cabo los 3 días de 6:00am a 10:00pm, al lugar solo asistirán entrenadores y boxeadores, quedará restringida la entrada a padres de familia.',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('Rechazar', const Color(0xFF980808)),
              _buildButton('Aceptar', Colors.green.shade700),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}