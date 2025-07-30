import 'package:flutter/material.dart';
import 'package:capbox/features/coach/domain/entities/student_model.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_navbar.dart';
import 'admin_student_profile_page.dart'; // Asegúrate de importar la página de perfil
import 'package:provider/provider.dart';
import '../cubit/admin_gym_key_cubit.dart';

class AdminManageStudentsPage extends StatefulWidget {
  const AdminManageStudentsPage({super.key});

  @override
  State<AdminManageStudentsPage> createState() =>
      _AdminManageStudentsPageState();
}

class _AdminManageStudentsPageState extends State<AdminManageStudentsPage> {
  final List<Student> allStudents = [
    Student(name: "Arturo Amizaday Jimenez Ojendis"),
    Student(name: "Ana Karen Álvarez Borralles"),
    Student(name: "Jonathan Dzul Mendoza"),
    Student(name: "Nuricumbo Jimenez Pedregal"),
    Student(name: "Alberto Taboada De La Cruz"),
  ];

  String searchText = '';

  Future<void> _activarCoachesExistentes() async {
    try {
      final cubit = Provider.of<AdminGymKeyCubit>(context, listen: false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activando coaches existentes...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      final result = await cubit.activarCoachesExistentes();

      final coachesActivados = result['coachesActivados'] ?? 0;
      final coachesYaActivos = result['coachesYaActivos'] ?? 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Coaches activados exitosamente\n'
            'Coaches activados: $coachesActivados\n'
            'Coaches ya activos: $coachesYaActivos',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error activando coaches: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        allStudents
            .where(
              (student) =>
                  student.name.toLowerCase().contains(searchText.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      bottomNavigationBar: const AdminNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminHeader(),
                  const SizedBox(height: 24),
                  // Botón para activar coaches existentes
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: _activarCoachesExistentes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text(
                        '🔧 Activar Coaches Existentes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Gestionar alumno:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => setState(() => searchText = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar alumno',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black54,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ordenar por: ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Text(
                    'Orden alfabético',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final student = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AdminStudentProfilePage(
                                      student: student,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/images/usuario.png',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    student.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
