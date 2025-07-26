import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:capbox/features/admin/presentation/cubit/gym_management_cubit.dart';

class CoachSelectStudentPage extends StatefulWidget {
  const CoachSelectStudentPage({super.key});

  @override
  State<CoachSelectStudentPage> createState() => _CoachSelectStudentPageState();
}

class _CoachSelectStudentPageState extends State<CoachSelectStudentPage> {
  @override
  void initState() {
    super.initState();
    // Cargar estudiantes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymManagementCubit>().loadMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CoachNavBar(currentIndex: 1),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CoachHeader(),
                  const SizedBox(height: 20),
                  const Text(
                    'Asignar meta personal a:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _buildSearchField(),
                  const SizedBox(height: 10),
                  const Text(
                    'Ordenar por: Orden alfabético',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  _buildStudentsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar alumno',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (query) {
        context.read<GymManagementCubit>().searchMembers(query);
      },
    );
  }

  Widget _buildStudentsList() {
    return Consumer<GymManagementCubit>(
      builder: (context, gymCubit, child) {
        if (gymCubit.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (gymCubit.hasError) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  gymCubit.errorMessage ?? 'Error cargando estudiantes',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => gymCubit.loadMembers(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final students = gymCubit.getStudents();

        if (students.isEmpty) {
          return const Center(
            child: Text(
              'No hay estudiantes disponibles',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink,
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle:
                        student.athleteProfile != null
                            ? Text(
                              '${student.athleteProfile!.level} • ${student.athleteProfile!.statsDescription}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            )
                            : Text(
                              student.role,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        student.name,
                      ); // Regresa el nombre del estudiante
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
