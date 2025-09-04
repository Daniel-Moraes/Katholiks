/// 🏆 Conquistas do usuário
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementType type;
  final int requiredCount;
  final DateTime unlockedAt;
  final int points;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.type,
    required this.requiredCount,
    required this.unlockedAt,
    required this.points,
  });

  /// Converte Achievement para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'type': type.name,
      'requiredCount': requiredCount,
      'unlockedAt': unlockedAt.toIso8601String(),
      'points': points,
    };
  }

  /// Cria Achievement a partir de Map (do Firestore)
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.firstRosary,
      ),
      requiredCount: map['requiredCount'] ?? 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : DateTime.now(),
      points: map['points'] ?? 0,
    );
  }

  /// Cria uma cópia com alterações
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    AchievementType? type,
    int? requiredCount,
    DateTime? unlockedAt,
    int? points,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
      requiredCount: requiredCount ?? this.requiredCount,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      points: points ?? this.points,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.iconName == iconName &&
        other.type == type &&
        other.requiredCount == requiredCount &&
        other.unlockedAt == unlockedAt &&
        other.points == points;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        iconName.hashCode ^
        type.hashCode ^
        requiredCount.hashCode ^
        unlockedAt.hashCode ^
        points.hashCode;
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, type: $type, points: $points)';
  }
}

/// 🏆 Tipos de conquistas
enum AchievementType {
  firstRosary, // Primeiro terço
  dailyStreak, // Sequência diária
  weeklyGoal, // Meta semanal
  monthlyGoal, // Meta mensal
  mysteryMaster, // Domínio de mistérios
  speedPrayer, // Oração rápida
  contemplative, // Oração contemplativa
  dedication, // Dedicação
  consistency, // Consistência
  milestones, // Marcos importantes
}

/// 🏆 Extensões para AchievementType
extension AchievementTypeExtension on AchievementType {
  /// Título legível do tipo de conquista
  String get displayTitle {
    switch (this) {
      case AchievementType.firstRosary:
        return 'Primeiro Terço';
      case AchievementType.dailyStreak:
        return 'Sequência Diária';
      case AchievementType.weeklyGoal:
        return 'Meta Semanal';
      case AchievementType.monthlyGoal:
        return 'Meta Mensal';
      case AchievementType.mysteryMaster:
        return 'Mestre dos Mistérios';
      case AchievementType.speedPrayer:
        return 'Oração Rápida';
      case AchievementType.contemplative:
        return 'Contemplativo';
      case AchievementType.dedication:
        return 'Dedicação';
      case AchievementType.consistency:
        return 'Consistência';
      case AchievementType.milestones:
        return 'Marcos Importantes';
    }
  }

  /// Descrição do tipo de conquista
  String get description {
    switch (this) {
      case AchievementType.firstRosary:
        return 'Complete seu primeiro Santo Terço';
      case AchievementType.dailyStreak:
        return 'Mantenha uma sequência diária de orações';
      case AchievementType.weeklyGoal:
        return 'Alcance sua meta semanal de terços';
      case AchievementType.monthlyGoal:
        return 'Complete sua meta mensal de orações';
      case AchievementType.mysteryMaster:
        return 'Domine todos os tipos de mistérios';
      case AchievementType.speedPrayer:
        return 'Complete um terço em tempo recorde';
      case AchievementType.contemplative:
        return 'Dedique tempo extra à contemplação';
      case AchievementType.dedication:
        return 'Demonstre dedicação constante';
      case AchievementType.consistency:
        return 'Mantenha regularidade nas orações';
      case AchievementType.milestones:
        return 'Alcance marcos importantes na jornada';
    }
  }

  /// Ícone padrão para o tipo
  String get defaultIcon {
    switch (this) {
      case AchievementType.firstRosary:
        return 'star';
      case AchievementType.dailyStreak:
        return 'fire';
      case AchievementType.weeklyGoal:
        return 'calendar_week';
      case AchievementType.monthlyGoal:
        return 'calendar_month';
      case AchievementType.mysteryMaster:
        return 'psychology';
      case AchievementType.speedPrayer:
        return 'speed';
      case AchievementType.contemplative:
        return 'self_improvement';
      case AchievementType.dedication:
        return 'favorite';
      case AchievementType.consistency:
        return 'check_circle';
      case AchievementType.milestones:
        return 'emoji_events';
    }
  }
}
