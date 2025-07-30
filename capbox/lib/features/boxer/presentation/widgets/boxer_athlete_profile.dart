import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/aws_api_service.dart';
import '../../../../core/services/user_display_service.dart';

class BoxerAthleteProfile extends StatefulWidget {
  const BoxerAthleteProfile({super.key});

  @override
  State<BoxerAthleteProfile> createState() => _BoxerAthleteProfileState();
}

class _BoxerAthleteProfileState extends State<BoxerAthleteProfile> {
  Map<String, dynamic>? _athleteData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAthleteData();
  }

  Future<void> _loadAthleteData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiService = context.read<AWSApiService>();
      final response = await apiService.getUserMe();
      final userData = response.data;

      setState(() {
        _athleteData = userData;
        _isLoading = false;
      });

      print('🏃 BOXER PROFILE: Datos del atleta cargados');
      print('📊 BOXER PROFILE: Datos recibidos - $userData');
    } catch (e) {
      print('❌ BOXER PROFILE: Error cargando datos - $e');
      setState(() {
        _errorMessage = 'Error cargando datos del atleta';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 120, // Misma altura que el contenedor principal
        decoration: BoxDecoration(
          color: Colors.grey[800]!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 120, // Misma altura que el contenedor principal
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 120, // Reducir altura ya que no hay datos físicos
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar del atleta
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getAvatarInitial(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información del atleta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nombre del atleta
                  Flexible(
                    child: Text(
                      _getAthleteName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 8), // Aumentar espaciado
                  // Nivel del atleta
                  Text(
                    _getAthleteLevel(),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Remover datos físicos - no mostrar nada
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAvatarInitial() {
    if (_athleteData == null) return 'A';

    final name =
        _athleteData!['nombre'] ??
        _athleteData!['name'] ??
        _athleteData!['displayName'] ??
        '';
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return 'A';
  }

  String _getAthleteName() {
    if (_athleteData == null) return 'Atleta';

    // Priorizar diferentes campos de nombre
    final nombre = _athleteData!['nombre'];
    final name = _athleteData!['name'];
    final displayName = _athleteData!['displayName'];
    final fullName = _athleteData!['fullName'];

    return nombre ?? name ?? displayName ?? fullName ?? 'Atleta';
  }

  String _getAthleteLevel() {
    if (_athleteData == null) return 'PRINCIPIANTE';

    final nivel = _athleteData!['nivel'] ?? 'principiante';
    return nivel.toString().toUpperCase();
  }

  String _getPhysicalData() {
    // Eliminar datos físicos simulados - no mostrar nada hasta que el backend esté listo
    return '';
  }
}
