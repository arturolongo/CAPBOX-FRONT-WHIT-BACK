import 'package:flutter/material.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_header.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_navbar.dart';
import 'package:go_router/go_router.dart';

class CoachSelectStudentForTestPage extends StatefulWidget {
  const CoachSelectStudentForTestPage({super.key});

  @override
  State<CoachSelectStudentForTestPage> createState() => _CoachSelectStudentForTestPageState();
}

class _CoachSelectStudentForTestPageState extends State<CoachSelectStudentForTestPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> alumnos = [
    'Arturo Amizaday Jimenez Ojendis',
    'Ana Karen Álvarez Borralles',
    'Jonathan Dzul Mendoza',
    'Nuricumbo Jimenez Pedregal',
    'Alberto Taboada De La Cruz',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Column(
              children: [
                const CoachHeader(),
                const SizedBox(height: 12),
                const Text(
                  'Seleccionar alumno para tomar pruebas',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar alumno',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.purpleAccent),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ordenar por: ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Orden alfabético',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: alumnos
                        .where((alumno) => alumno.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .map((alumno) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundImage: AssetImage('assets/images/boxer.png'),
                                  ),
                                  title: Text(alumno, style: const TextStyle(color: Colors.white)),
                                  onTap: () {
                                    context.go('/coach/student-profile');
                                  },
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const CoachNavBar(currentIndex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}