/// 📿 Modelo para representar uma oração do terço
class Prayer {
  final String id;
  final String title;
  final String text;
  final String? audioUrl;
  final int repetitions;
  final PrayerType type;
  final String? instruction;
  final Duration? recommendedPace;

  const Prayer({
    required this.id,
    required this.title,
    required this.text,
    this.audioUrl,
    required this.repetitions,
    required this.type,
    this.instruction,
    this.recommendedPace,
  });
}

/// 📿 Tipos de oração no terço
enum PrayerType {
  signal, // Sinal da Cruz
  creed, // Creio
  ourFather, // Pai Nosso
  hailMary, // Ave Maria
  glory, // Glória
  fatimaPrayer, // Oração de Fátima
  finalPrayer, // Oração final
}

/// 🔮 Mistérios do Rosário
class Mystery {
  final String id;
  final String title;
  final String description;
  final String reflection;
  final String? imageUrl;
  final MysteryType type;
  final List<String> intentions;

  const Mystery({
    required this.id,
    required this.title,
    required this.description,
    required this.reflection,
    this.imageUrl,
    required this.type,
    required this.intentions,
  });
}

/// 🔮 Tipos de mistérios
enum MysteryType {
  joyful, // Gozosos (Segunda e Sábado)
  sorrowful, // Dolorosos (Terça e Sexta)
  glorious, // Gloriosos (Quarta e Domingo)
  luminous, // Luminosos (Quinta)
}

/// 📿 Sessão completa do terço
class RosarySession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final MysteryType mysteryType;
  final List<Mystery> mysteries;
  final int currentMystery;
  final int currentDecade;
  final int currentPrayer;
  final int totalPrayers;
  final int completedPrayers;
  final List<Achievement> achievedMilestones;
  final RosarySessionStatus status;
  final Map<String, int> prayerCounts;

  const RosarySession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.mysteryType,
    required this.mysteries,
    required this.currentMystery,
    required this.currentDecade,
    required this.currentPrayer,
    required this.totalPrayers,
    required this.completedPrayers,
    required this.achievedMilestones,
    required this.status,
    required this.prayerCounts,
  });

  /// Progresso da sessão (0.0 a 1.0)
  double get progress =>
      totalPrayers > 0 ? completedPrayers / totalPrayers : 0.0;

  /// Tempo decorrido da sessão
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Cópia com mudanças
  RosarySession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    MysteryType? mysteryType,
    List<Mystery>? mysteries,
    int? currentMystery,
    int? currentDecade,
    int? currentPrayer,
    int? totalPrayers,
    int? completedPrayers,
    List<Achievement>? achievedMilestones,
    RosarySessionStatus? status,
    Map<String, int>? prayerCounts,
  }) {
    return RosarySession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      mysteryType: mysteryType ?? this.mysteryType,
      mysteries: mysteries ?? this.mysteries,
      currentMystery: currentMystery ?? this.currentMystery,
      currentDecade: currentDecade ?? this.currentDecade,
      currentPrayer: currentPrayer ?? this.currentPrayer,
      totalPrayers: totalPrayers ?? this.totalPrayers,
      completedPrayers: completedPrayers ?? this.completedPrayers,
      achievedMilestones: achievedMilestones ?? this.achievedMilestones,
      status: status ?? this.status,
      prayerCounts: prayerCounts ?? this.prayerCounts,
    );
  }
}

/// 📊 Status da sessão
enum RosarySessionStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  abandoned,
}

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

/// 📊 Estatísticas do usuário
class RosaryStats {
  final int totalRosariesCompleted;
  final int currentStreak;
  final int longestStreak;
  final Duration totalPrayerTime;
  final Map<MysteryType, int> mysteriesCompleted;
  final Map<String, int> dailyGoals;
  final int totalAchievements;
  final int totalPoints;
  final DateTime? lastPrayer;
  final double averageSessionDuration;

  const RosaryStats({
    required this.totalRosariesCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPrayerTime,
    required this.mysteriesCompleted,
    required this.dailyGoals,
    required this.totalAchievements,
    required this.totalPoints,
    this.lastPrayer,
    required this.averageSessionDuration,
  });

  /// Nível do usuário baseado nos pontos
  int get userLevel => (totalPoints / 100).floor() + 1;

  /// Pontos necessários para o próximo nível
  int get pointsToNextLevel => ((userLevel * 100) - totalPoints).clamp(0, 100);

  /// Progresso para o próximo nível (0.0 a 1.0)
  double get levelProgress {
    final currentLevelPoints = totalPoints % 100;
    return currentLevelPoints / 100;
  }
}
