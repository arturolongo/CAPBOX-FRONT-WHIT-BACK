import 'package:flutter/material.dart';

class RoutineCardManage extends StatelessWidget {
  final Map<String, dynamic> rutina;
  final String nivel;
  final int index;
  final int? expandedIndex;
  final String selectedCategory;
  final Function(int) onExpand;
  final Function(String) onCategoryChange;

  const RoutineCardManage({
    super.key,
    required this.rutina,
    required this.nivel,
    required this.index,
    required this.expandedIndex,
    required this.selectedCategory,
    required this.onExpand,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = expandedIndex == index;
    final ejerciciosCategoria = rutina['categorias'][selectedCategory] as List<dynamic>? ?? [];

    return GestureDetector(
      onTap: () => onExpand(isExpanded ? -1 : index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rutina['titulo'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                Text('${rutina['ejercicios']} ejercicios', style: const TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(rutina['duracion'], style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 6),
            Text(nivel, style: const TextStyle(color: Colors.red)),

            if (isExpanded) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['calentamiento', 'resistencia', 'tecnica'].map((cat) {
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => onCategoryChange(cat),
                    child: Text(
                      cat[0].toUpperCase() + cat.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey),
                    verticalInside: BorderSide(color: Colors.red),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.5),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.red),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Text(
                              'Ejercicio',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Text(
                              'Cantidad',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...ejerciciosCategoria.map<TableRow>((e) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Center(
                              child: Text(
                                e['nombre'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Center(
                              child: Text(
                                e['duracion'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.grey.shade900,
                        title: const Text(
                          'Éxito',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Rutina eliminada correctamente',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Aceptar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 184, 19, 19)),
                  child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}