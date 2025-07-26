import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoxerEventsList extends StatelessWidget {
  const BoxerEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus eventos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          context,
          'assets/images/event1.png',
          'Guadalajara',
          '7 - 10 de octubre 2025',
          '\$1500',
          'Este evento tiene como lapso máximo a pagar el 1 de octubre del año en curso, el alojamiento se encuentra a 10 minutos del lugar del evento.',
          showCancel: true,
          showPending: true,
        ),
        const SizedBox(height: 24),
        const Text(
          'Invitaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          context,
          'assets/images/event2.png',
          'Tuxtla Gutierrez',
          '23 - 25 de febrero 2025',
          'Gratuito',
          'El evento se llevará a cabo los 3 días de 6:00am a 10:00pm, al lugar solo asistirán entrenadores y boxeadores, quedará restringida la entrada a padres de familia.',
          isInvitation: true,
        ),
      ],
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String imagePath,
    String location,
    String date,
    String cost,
    String description, {
    bool showCancel = false,
    bool showPending = false,
    bool isInvitation = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(imagePath, height: 100, width: 80, fit: BoxFit.cover),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelValue('Lugar: ', location),
                    _buildLabelValue('Fecha: ', date),
                    _buildLabelValue('Costo total de asistencia: ', cost),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showCancel)
              _buildButton('Cancelar asistencia', const Color(0xFF980808)),
            if (showCancel && showPending) const SizedBox(width: 8),
            if (showPending)
              _buildButton('Pago pendiente', const Color(0xFFAD9C00)),
            // dentro del _buildEventCard (solo el botón)
            if (isInvitation)
              GestureDetector(
                onTap: () {
                  context.push('/invitation-detail');
                },
                child: _buildButton('Ver invitación', const Color(0xFF0076AD)),
              ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}