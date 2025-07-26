import '../../../auth/domain/entities/user.dart';

enum AthleteStance { orthodox, southpaw, switcher }

class Athlete {
  final String userId; // FK to users table
  final User? userInfo; // Populated when needed
  final String level;
  final double heightCm;
  final double weightKg;
  final AthleteStance stance;
  final String? allergies;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  Athlete({
    required this.userId,
    this.userInfo,
    required this.level,
    required this.heightCm,
    required this.weightKg,
    required this.stance,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  Athlete copyWith({
    String? userId,
    User? userInfo,
    String? level,
    double? heightCm,
    double? weightKg,
    AthleteStance? stance,
    String? allergies,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return Athlete(
      userId: userId ?? this.userId,
      userInfo: userInfo ?? this.userInfo,
      level: level ?? this.level,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      stance: stance ?? this.stance,
      allergies: allergies ?? this.allergies,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }

  // Helper getters
  String get name => userInfo?.name ?? '';
  String get email => userInfo?.email ?? '';
  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));
}
