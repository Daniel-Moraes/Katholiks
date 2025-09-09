import 'achievement.dart';

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
  final List<RosaryPrayerStep> prayerSteps;
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
    required this.prayerSteps,
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

  RosarySession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    MysteryType? mysteryType,
    List<Mystery>? mysteries,
    List<RosaryPrayerStep>? prayerSteps,
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
      prayerSteps: prayerSteps ?? this.prayerSteps,
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

class RosaryPrayers {
  static const String sinalDaCruz =
      '''Em nome do Pai, e do Filho, e do Espírito Santo. Amém.''';

  static const String creio =
      '''Creio em Deus Pai todo-poderoso, criador do céu e da terra. E em Jesus Cristo, seu único Filho, nosso Senhor, que foi concebido pelo poder do Espírito Santo; nasceu da Virgem Maria; padeceu sob Pôncio Pilatos, foi crucificado, morto e sepultado; desceu à mansão dos mortos; ressuscitou ao terceiro dia; subiu aos céus, está sentado à direita de Deus Pai todo-poderoso, donde há de vir a julgar os vivos e os mortos. Creio no Espírito Santo, na Santa Igreja Católica, na comunhão dos santos, na remissão dos pecados, na ressurreição da carne e na vida eterna. Amém.''';

  static const String paiNosso =
      '''Pai nosso, que estais nos céus, santificado seja o vosso nome; venha a nós o vosso reino; seja feita a vossa vontade, assim na terra como no céu. O pão nosso de cada dia nos dai hoje; perdoai-nos as nossas ofensas, assim como nós perdoamos a quem nos tem ofendido; e não nos deixeis cair em tentação, mas livrai-nos do mal. Amém.''';

  static const String aveMaria =
      '''Ave Maria, cheia de graça, o Senhor é convosco; bendita sois vós entre as mulheres, e bendito é o fruto do vosso ventre, Jesus. Santa Maria, Mãe de Deus, rogai por nós, pecadores, agora e na hora da nossa morte. Amém.''';

  static const String gloria =
      '''Glória ao Pai, ao Filho e ao Espírito Santo. Como era no princípio, agora e sempre. Amém.''';

  static const String fatima =
      '''Ó meu Jesus, perdoai-nos, livrai-nos do fogo do inferno, levai as almas todas para o céu e socorrei principalmente aquelas que mais precisarem da vossa misericórdia.''';

  static const String salveRainha =
      '''Salve, Rainha, Mãe de misericórdia, vida, doçura e esperança nossa, salve! A vós bradamos, os degredados filhos de Eva; a vós suspiramos, gemendo e chorando neste vale de lágrimas. Eia, pois, advogada nossa, esses vossos olhos misericordiosos a nós volvei; e depois deste desterro mostrai-nos Jesus, bendito fruto do vosso ventre, ó clemente, ó piedosa, ó doce sempre Virgem Maria! Rogai por nós, Santa Mãe de Deus, para que sejamos dignos das promessas de Cristo. Amém.''';
}

/// 🔮 Tipos de oração expandidos
enum PrayerTypeExpanded {
  sinalDaCruz('Sinal da Cruz', RosaryPrayers.sinalDaCruz),
  creio('Creio', RosaryPrayers.creio),
  paiNosso('Pai Nosso', RosaryPrayers.paiNosso),
  aveMaria('Ave Maria', RosaryPrayers.aveMaria),
  gloria('Glória ao pai', RosaryPrayers.gloria),
  fatima('Oração de Fátima', RosaryPrayers.fatima),
  salveRainha('Salve Rainha', RosaryPrayers.salveRainha),
  mysteryIntroduction(
      'Contemplação do Mistério', ''); // Texto será definido dinamicamente

  const PrayerTypeExpanded(this.title, this.text);
  final String title;
  final String text;
}

/// 📿 Passo individual do terço
class RosaryPrayerStep {
  final PrayerTypeExpanded type;
  final int mysteryIndex;
  final int prayerInMystery;
  final String? mysteryReflection;
  final Mystery? currentMystery;
  final String? customText; // Para textos dinâmicos como introdução de mistério

  const RosaryPrayerStep({
    required this.type,
    this.mysteryIndex = -1,
    this.prayerInMystery = -1,
    this.mysteryReflection,
    this.currentMystery,
    this.customText,
  });

  bool get isInMystery => mysteryIndex >= 0;
  bool get isDecadePrayer => prayerInMystery >= 0;

  /// Retorna o texto a ser exibido (customText tem prioridade sobre type.text)
  String get displayText => customText ?? type.text;
}
