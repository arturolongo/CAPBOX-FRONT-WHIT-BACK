class Sport {
  final String id;
  final String name;

  Sport({required this.id, required this.name});

  Sport copyWith({String? id, String? name}) {
    return Sport(id: id ?? this.id, name: name ?? this.name);
  }
}
