class Gym {
  final String id;
  final String ownerId; // FK to users
  final String gymKey; // Unique identifier for gym
  final String name;

  Gym({
    required this.id,
    required this.ownerId,
    required this.gymKey,
    required this.name,
  });

  Gym copyWith({String? id, String? ownerId, String? gymKey, String? name}) {
    return Gym(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      gymKey: gymKey ?? this.gymKey,
      name: name ?? this.name,
    );
  }
}

class UserGymRelation {
  final String userId;
  final String gymId;

  UserGymRelation({required this.userId, required this.gymId});
}
