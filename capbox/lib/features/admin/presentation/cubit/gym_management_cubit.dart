import 'package:flutter/foundation.dart';
import '../../data/dtos/gym_member_dto.dart';
import '../../data/services/gym_service.dart';

/// Estados para la gestión del gimnasio
enum GymManagementState { initial, loading, loaded, error }

/// Cubit para manejar miembros del gimnasio
class GymManagementCubit extends ChangeNotifier {
  final GymService _gymService;

  GymManagementState _state = GymManagementState.initial;
  List<GymMemberDto> _allMembers = [];
  List<GymMemberDto> _filteredMembers = [];
  List<GymMemberDto> _pendingRequests = [];
  String? _errorMessage;
  String _currentFilter = '';

  GymManagementCubit(this._gymService);

  // Getters
  GymManagementState get state => _state;
  List<GymMemberDto> get members => _filteredMembers;
  List<GymMemberDto> get allMembers => _allMembers;
  List<GymMemberDto> get pendingRequests => _pendingRequests;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == GymManagementState.loading;
  bool get hasError => _state == GymManagementState.error;
  bool get isEmpty => _filteredMembers.isEmpty;

  /// Cargar todos los miembros del gimnasio
  Future<void> loadMembers() async {
    try {
      _setState(GymManagementState.loading);
      _clearError();

      print('🏋️ CUBIT: Cargando miembros del gimnasio');

      // Intentar cargar desde el backend
      try {
        final members = await _gymService.getGymMembers();
        _allMembers = members;
        print('✅ CUBIT: ${members.length} miembros cargados desde backend');

        // 🆕 DIAGNÓSTICO DETALLADO DEL CUBIT
        print('🔍 CUBIT: === DIAGNÓSTICO DE MIEMBROS ===');
        print('👥 CUBIT: Total de miembros: ${members.length}');

        // Contar por roles
        final atletas = members.where((m) => m.isAthlete).toList();
        final entrenadores = members.where((m) => m.isCoach).toList();
        final admins = members.where((m) => m.isAdmin).toList();

        print('🏃 CUBIT: Atletas: ${atletas.length}');
        print('👨‍🏫 CUBIT: Entrenadores: ${entrenadores.length}');
        print('👑 CUBIT: Admins: ${admins.length}');

        // Mostrar detalles de cada entrenador
        if (entrenadores.isNotEmpty) {
          print('👨‍🏫 CUBIT: Detalles de entrenadores:');
          for (final coach in entrenadores) {
            print('   - ${coach.name} (${coach.email}) - ${coach.role}');
          }
        } else {
          print('⚠️ CUBIT: NO HAY ENTRENADORES EN LA LISTA');
        }

        // Mostrar detalles de cada atleta
        if (atletas.isNotEmpty) {
          print('🏃 CUBIT: Detalles de atletas:');
          for (final athlete in atletas.take(3)) {
            // Solo primeros 3
            print('   - ${athlete.name} (${athlete.email}) - ${athlete.role}');
          }
          if (atletas.length > 3) {
            print('   ... y ${atletas.length - 3} más');
          }
        }
      } catch (e) {
        print('⚠️ CUBIT: Error cargando desde backend, usando datos mock');
        _allMembers = _getMockMembers();
      }

      _applyCurrentFilter();
      _setState(GymManagementState.loaded);
    } catch (e) {
      print('❌ CUBIT: Error cargando miembros - $e');
      _setError('Error cargando miembros del gimnasio: $e');
      _setState(GymManagementState.error);
    }
  }

  /// Cargar solicitudes pendientes (para admins)
  Future<void> loadPendingRequests() async {
    try {
      print('🏋️ CUBIT: Cargando solicitudes pendientes');

      // Intentar cargar desde el backend
      try {
        final requests = await _gymService.getPendingRequests();
        _pendingRequests = requests;
        print('✅ CUBIT: ${requests.length} solicitudes pendientes');
      } catch (e) {
        print('⚠️ CUBIT: Error cargando solicitudes, usando datos mock');
        _pendingRequests = _getMockPendingRequests();
      }

      notifyListeners();
    } catch (e) {
      print('❌ CUBIT: Error cargando solicitudes - $e');
      _setError('Error cargando solicitudes pendientes: $e');
    }
  }

  /// Filtrar miembros por texto de búsqueda
  void searchMembers(String query) {
    _currentFilter = query;
    _applyCurrentFilter();
    notifyListeners();
  }

  /// Filtrar miembros por rol
  void filterByRole(String role) {
    if (role.isEmpty || role.toLowerCase() == 'todos') {
      _filteredMembers = List.from(_allMembers);
    } else {
      _filteredMembers =
          _allMembers
              .where(
                (member) => member.role.toLowerCase() == role.toLowerCase(),
              )
              .toList();
    }
    notifyListeners();
  }

  /// Obtener solo estudiantes (atletas)
  List<GymMemberDto> getStudents() {
    return _allMembers.where((member) => member.isAthlete).toList();
  }

  /// Obtener solo entrenadores
  List<GymMemberDto> getCoaches() {
    return _allMembers.where((member) => member.isCoach).toList();
  }

  /// Obtener un miembro específico por ID
  GymMemberDto? getMemberById(String id) {
    try {
      return _allMembers.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Aplicar filtro actual
  void _applyCurrentFilter() {
    if (_currentFilter.isEmpty) {
      _filteredMembers = List.from(_allMembers);
    } else {
      _filteredMembers =
          _allMembers
              .where(
                (member) =>
                    member.name.toLowerCase().contains(
                      _currentFilter.toLowerCase(),
                    ) ||
                    member.email.toLowerCase().contains(
                      _currentFilter.toLowerCase(),
                    ) ||
                    member.role.toLowerCase().contains(
                      _currentFilter.toLowerCase(),
                    ),
              )
              .toList();
    }
  }

  /// Obtener datos mock cuando el backend no esté disponible
  List<GymMemberDto> _getMockMembers() {
    return [
      GymMemberDto.mock(
        id: '1',
        name: 'Arturo Amizaday Jimenez Ojendis',
        role: 'atleta',
      ),
      GymMemberDto.mock(
        id: '2',
        name: 'Ana Karen Álvarez Borralles',
        role: 'atleta',
      ),
      GymMemberDto.mock(id: '3', name: 'Jonathan Dzul Mendoza', role: 'atleta'),
      GymMemberDto.mock(id: '4', name: 'Juan Jimenez', role: 'atleta'),
      GymMemberDto.mock(
        id: '5',
        name: 'Nuricumbo Jimenez Pedregal',
        role: 'atleta',
      ),
      GymMemberDto.mock(
        id: '6',
        name: 'Alberto Taboada De La Cruz',
        role: 'atleta',
      ),
      GymMemberDto.mock(id: '7', name: 'Carlos Fernandez', role: 'entrenador'),
      GymMemberDto.mock(id: '8', name: 'Fernando Dinamita', role: 'entrenador'),
    ];
  }

  /// Obtener solicitudes pendientes mock
  List<GymMemberDto> _getMockPendingRequests() {
    return [
      GymMemberDto.mock(
        id: '9',
        name: 'Pedro Martinez',
        role: 'atleta',
        status: 'pending',
      ),
      GymMemberDto.mock(
        id: '10',
        name: 'Maria Rodriguez',
        role: 'atleta',
        status: 'pending',
      ),
    ];
  }

  /// Aprobar un atleta con datos completos (para entrenadores)
  Future<void> approveAthleteWithData({
    required String athleteId,
    required Map<String, dynamic> physicalData,
    required Map<String, dynamic> tutorData,
  }) async {
    try {
      print('🏋️ CUBIT: Aprobando atleta $athleteId con datos completos');

      await _gymService.approveAthleteWithData(
        athleteId: athleteId,
        physicalData: physicalData,
        tutorData: tutorData,
      );

      // Actualizar listas locales
      _pendingRequests.removeWhere((member) => member.id == athleteId);

      // Recargar miembros para incluir el recién aprobado
      await loadMembers();

      print('✅ CUBIT: Atleta aprobado exitosamente con datos completos');
    } catch (e) {
      print('❌ CUBIT: Error aprobando atleta - $e');
      _setError('Error aprobando atleta: $e');
    }
  }

  /// Recargar datos
  Future<void> refresh() async {
    await loadMembers();
    await loadPendingRequests();
  }

  /// Helpers privados
  void _setState(GymManagementState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
