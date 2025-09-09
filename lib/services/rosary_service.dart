import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import '../models/rosary.dart';
import '../models/achievement.dart';
import 'rosary_firestore_service.dart';

class RosaryService extends ChangeNotifier {
  static RosaryService? _instance;

  RosaryService._internal();

  static RosaryService get instance {
    _instance ??= RosaryService._internal();
    return _instance!;
  }

  final RosaryFirestoreService _firestoreService = RosaryFirestoreService();
  RosarySession? _currentSession;
  RosaryStats _stats = const RosaryStats(
    totalRosariesCompleted: 0,
    currentStreak: 0,
    longestStreak: 0,
    totalPrayerTime: Duration.zero,
    mysteriesCompleted: {},
    dailyGoals: {},
    totalAchievements: 0,
    totalPoints: 0,
    averageSessionDuration: 0,
  );

  RosarySession? get currentSession => _currentSession;
  RosaryStats get stats => _stats;
  bool get isSessionActive =>
      _currentSession?.status == RosarySessionStatus.inProgress;

  Future<void> initialize() async {
    try {
      final savedStats = await _firestoreService.loadUserStats();
      if (savedStats != null) {
        _stats = savedStats;
      } else {
        _stats = await _firestoreService.createInitialStats();
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Erro ao inicializar RosaryService: $e');
      _stats = const RosaryStats(
        totalRosariesCompleted: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalPrayerTime: Duration.zero,
        mysteriesCompleted: {},
        dailyGoals: {},
        totalAchievements: 0,
        totalPoints: 0,
        averageSessionDuration: 0,
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  MysteryType getTodaysMystery() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case DateTime.monday:
      case DateTime.saturday:
        return MysteryType.joyful;
      case DateTime.tuesday:
      case DateTime.friday:
        return MysteryType.sorrowful;
      case DateTime.wednesday:
      case DateTime.sunday:
        return MysteryType.glorious;
      case DateTime.thursday:
        return MysteryType.luminous;
      default:
        return MysteryType.joyful;
    }
  }

  Future<List<Achievement>> getUserAchievements({int limit = 10}) async {
    try {
      final achievements = await _firestoreService.loadUserAchievements();
      if (limit > 0 && achievements.length > limit) {
        return achievements.take(limit).toList();
      }
      return achievements;
    } catch (e) {
      print('Erro ao buscar conquistas do usuário: $e');
      return [];
    }
  }

  Future<List<Achievement>> getUserAchievementsByType(
      AchievementType type) async {
    try {
      final achievements = await _firestoreService.loadUserAchievements();
      return achievements
          .where((achievement) => achievement.type == type)
          .toList();
    } catch (e) {
      print('Erro ao buscar conquistas por tipo: $e');
      return [];
    }
  }

  Future<RosarySession> startRosarySession({MysteryType? mysteryType}) async {
    _currentSession = null;

    final selectedMystery = mysteryType ?? getTodaysMystery();
    final mysteries = _getMysteries(selectedMystery);
    final prayerSteps = _generateRosarySequence(mysteries);

    _currentSession = RosarySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      mysteryType: selectedMystery,
      mysteries: mysteries,
      prayerSteps: prayerSteps,
      currentMystery: 0,
      currentDecade: 0,
      currentPrayer: 0,
      totalPrayers: prayerSteps.length,
      completedPrayers: 0,
      achievedMilestones: [],
      status: RosarySessionStatus.inProgress,
      prayerCounts: {},
    );

    HapticFeedback.lightImpact();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    return _currentSession!;
  }

  Future<RosarySession> startCompleteRosarySession() async {
    _currentSession = null;

    final allMysteries = [
      MysteryType.joyful,
      MysteryType.luminous,
      MysteryType.sorrowful,
      MysteryType.glorious,
    ];

    final List<Mystery> mysteries = [];
    for (final mysteryType in allMysteries) {
      mysteries.addAll(_getMysteries(mysteryType));
    }

    final prayerSteps = _generateCompleteRosarySequence(mysteries);

    _currentSession = RosarySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      mysteryType: MysteryType.joyful, // Começa com os gozosos
      mysteries: mysteries,
      prayerSteps: prayerSteps,
      currentMystery: 0,
      currentDecade: 0,
      currentPrayer: 0,
      totalPrayers: prayerSteps.length,
      completedPrayers: 0,
      achievedMilestones: [],
      status: RosarySessionStatus.inProgress,
      prayerCounts: {},
    );

    HapticFeedback.lightImpact();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    return _currentSession!;
  }

  void pauseSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: RosarySessionStatus.paused,
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void resumeSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: RosarySessionStatus.inProgress,
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void clearCurrentSession() {
    _currentSession = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<bool> nextPrayer() async {
    if (_currentSession == null) return false;

    final newCompleted = _currentSession!.completedPrayers + 1;
    final newSession = _currentSession!.copyWith(
      completedPrayers: newCompleted,
    );

    if (newCompleted >= _currentSession!.totalPrayers) {
      await _completeSession();
      return true;
    }

    _updateCurrentPosition(newSession);

    HapticFeedback.selectionClick();

    if (newCompleted % 10 == 0) {
      HapticFeedback.mediumImpact();
    }

    _currentSession = newSession;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    return false;
  }

  bool previousPrayer() {
    if (_currentSession == null) return false;

    final newCompleted = _currentSession!.completedPrayers - 1;

    if (newCompleted < 0) return false;
    final newSession = _currentSession!.copyWith(
      completedPrayers: newCompleted,
    );

    _updateCurrentPosition(newSession);

    HapticFeedback.selectionClick();

    _currentSession = newSession;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    return true;
  }

  Future<void> _completeSession() async {
    if (_currentSession == null) return;

    final completedSession = _currentSession!.copyWith(
      status: RosarySessionStatus.completed,
      endTime: DateTime.now(),
    );

    await _updateStats(completedSession);

    final achievements = await _checkAchievements(completedSession);

    HapticFeedback.heavyImpact();

    final sessionToSave = completedSession.copyWith(
      achievedMilestones: achievements,
    );

    try {
      await _firestoreService.saveRosarySession(sessionToSave);
      await _firestoreService.saveUserStats(_stats);

      for (final achievement in achievements) {
        await _firestoreService.saveAchievement(achievement);
      }
    } catch (e) {
      print('Erro ao salvar sessão no Firebase: $e');
    }

    _currentSession = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> _updateStats(RosarySession session) async {
    final newStats = RosaryStats(
      totalRosariesCompleted: _stats.totalRosariesCompleted + 1,
      currentStreak: _calculateCurrentStreak(),
      longestStreak: _calculateLongestStreak(),
      totalPrayerTime: _stats.totalPrayerTime + session.elapsedTime,
      mysteriesCompleted: _updateMysteryCount(session.mysteryType),
      dailyGoals: _stats.dailyGoals,
      totalAchievements: _stats.totalAchievements,
      totalPoints: _stats.totalPoints + _calculatePoints(session),
      lastPrayer: DateTime.now(),
      averageSessionDuration: _calculateAverageDuration(session.elapsedTime),
    );

    _stats = newStats;
  }

  Future<List<Achievement>> _checkAchievements(RosarySession session) async {
    final List<Achievement> newAchievements = [];

    if (_stats.totalRosariesCompleted == 0) {
      newAchievements.add(Achievement(
        id: 'first_rosary',
        title: 'Primeiro Terço',
        description: 'Parabéns por completar seu primeiro terço!',
        iconName: 'celebration',
        type: AchievementType.firstRosary,
        requiredCount: 1,
        unlockedAt: DateTime.now(),
        points: 50,
      ));
    }

    if (_calculateCurrentStreak() >= 7) {
      newAchievements.add(Achievement(
        id: 'weekly_streak',
        title: 'Devoto Semanal',
        description: 'Rezou o terço por 7 dias seguidos!',
        iconName: 'streak',
        type: AchievementType.dailyStreak,
        requiredCount: 7,
        unlockedAt: DateTime.now(),
        points: 100,
      ));
    }

    if (_stats.totalRosariesCompleted + 1 >= 50) {
      newAchievements.add(Achievement(
        id: 'milestone_50',
        title: 'Devoto Fiel',
        description: 'Completou 50 terços! Nossa Senhora está orgulhosa.',
        iconName: 'crown',
        type: AchievementType.milestones,
        requiredCount: 50,
        unlockedAt: DateTime.now(),
        points: 250,
      ));
    }

    return newAchievements;
  }

  List<Mystery> _getMysteries(MysteryType type) {
    switch (type) {
      case MysteryType.joyful:
        return _joyfulMysteries;
      case MysteryType.sorrowful:
        return _sorrowfulMysteries;
      case MysteryType.glorious:
        return _gloriousMysteries;
      case MysteryType.luminous:
        return _luminousMysteries;
    }
  }

  List<RosaryPrayerStep> _generateRosarySequence(List<Mystery> mysteries) {
    List<RosaryPrayerStep> steps = [];

    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.sinalDaCruz));

    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.creio));

    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.paiNosso));

    for (int i = 0; i < 3; i++) {
      steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.aveMaria));
    }

    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.gloria));

    for (int mysteryIndex = 0;
        mysteryIndex < mysteries.length;
        mysteryIndex++) {
      final mystery = mysteries[mysteryIndex];

      // Adiciona a introdução do mistério como uma oração separada
      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.mysteryIntroduction,
        mysteryIndex: mysteryIndex,
        prayerInMystery: -1, // Não faz parte da dezena
        mysteryReflection: mystery.reflection,
        currentMystery: mystery,
        customText:
            'No ${mystery.title} nós contemplamos ${mystery.description}',
      ));

      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.paiNosso,
        mysteryIndex: mysteryIndex,
        prayerInMystery: 0,
        mysteryReflection: mystery.reflection,
        currentMystery: mystery,
      ));

      for (int ave = 1; ave <= 10; ave++) {
        steps.add(RosaryPrayerStep(
          type: PrayerTypeExpanded.aveMaria,
          mysteryIndex: mysteryIndex,
          prayerInMystery: ave,
          mysteryReflection: mystery.reflection,
          currentMystery: mystery,
        ));
      }

      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.gloria,
        mysteryIndex: mysteryIndex,
        prayerInMystery: 11,
        currentMystery: mystery,
      ));

      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.fatima,
        mysteryIndex: mysteryIndex,
        prayerInMystery: 12,
        currentMystery: mystery,
      ));
    }

    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.salveRainha));

    return steps;
  }

  List<RosaryPrayerStep> _generateCompleteRosarySequence(
      List<Mystery> mysteries) {
    List<RosaryPrayerStep> steps = [];

    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.sinalDaCruz));
    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.creio));
    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.paiNosso));

    for (int i = 0; i < 3; i++) {
      steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.aveMaria));
    }
    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.gloria));

    for (int mysteryIndex = 0;
        mysteryIndex < mysteries.length;
        mysteryIndex++) {
      final mystery = mysteries[mysteryIndex];

      // Adiciona a introdução do mistério como uma oração separada
      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.mysteryIntroduction,
        mysteryIndex: mysteryIndex,
        prayerInMystery: -1, // Não faz parte da dezena
        mysteryReflection: mystery.reflection,
        currentMystery: mystery,
        customText:
            'No ${mystery.title} nós contemplamos ${mystery.description}',
      ));

      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.paiNosso,
        mysteryIndex: mysteryIndex,
        prayerInMystery: 0,
        mysteryReflection: mystery.reflection,
        currentMystery: mystery,
      ));

      for (int ave = 1; ave <= 10; ave++) {
        steps.add(RosaryPrayerStep(
          type: PrayerTypeExpanded.aveMaria,
          mysteryIndex: mysteryIndex,
          prayerInMystery: ave,
          mysteryReflection: mystery.reflection,
          currentMystery: mystery,
        ));
      }

      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.gloria,
        mysteryIndex: mysteryIndex,
        prayerInMystery: 11,
        currentMystery: mystery,
      ));

      steps.add(RosaryPrayerStep(
        type: PrayerTypeExpanded.fatima,
        mysteryIndex: mysteryIndex,
        prayerInMystery: 12,
        currentMystery: mystery,
      ));
    }

    steps.add(const RosaryPrayerStep(type: PrayerTypeExpanded.salveRainha));

    return steps;
  }

  void _updateCurrentPosition(RosarySession session) {
    final progress = session.completedPrayers;
    final totalSteps = session.prayerSteps.length;

    if (progress < totalSteps) {
      final currentStep = session.prayerSteps[progress];
      if (currentStep.isInMystery) {
        session.copyWith(
          currentMystery: currentStep.mysteryIndex,
          currentDecade: currentStep.mysteryIndex,
        );
      }
    }
  }

  int _calculateCurrentStreak() {
    return _stats.currentStreak + 1;
  }

  int _calculateLongestStreak() {
    final currentStreak = _calculateCurrentStreak();
    return currentStreak > _stats.longestStreak
        ? currentStreak
        : _stats.longestStreak;
  }

  Map<MysteryType, int> _updateMysteryCount(MysteryType type) {
    final Map<MysteryType, int> updated = Map.from(_stats.mysteriesCompleted);
    updated[type] = (updated[type] ?? 0) + 1;
    return updated;
  }

  int _calculatePoints(RosarySession session) {
    int basePoints = 20;

    final minutes = session.elapsedTime.inMinutes;
    if (minutes >= 15 && minutes <= 25) {
      basePoints += 10;
    }

    if (session.status == RosarySessionStatus.completed) {
      basePoints += 10;
    }

    return basePoints;
  }

  double _calculateAverageDuration(Duration sessionDuration) {
    final totalSessions = _stats.totalRosariesCompleted + 1;
    final totalMinutes =
        _stats.totalPrayerTime.inMinutes + sessionDuration.inMinutes;
    return totalMinutes / totalSessions;
  }

  static const List<Mystery> _joyfulMysteries = [
    Mystery(
      id: 'joyful_1',
      title: '1º Mistério Gozoso',
      description:
          'O anúncio do Anjo, o "Sim" de Nossa Senhora e o Verbo Divino que se fez carne e habitou entre nós.',
      reflection:
          'Contemplemos a humildade de Maria ao aceitar ser a Mãe de Deus.',
      type: MysteryType.joyful,
      intentions: ['Pela humildade', 'Pelas vocações religiosas'],
    ),
    Mystery(
      id: 'joyful_2',
      title: '2º Mistério Gozoso',
      description:
          'A visita de Nossa Senhora à sua prima Santa Isabel e a santificação de João Batista.',
      reflection: 'Maria se apressa em servir, levando Jesus em seu ventre.',
      type: MysteryType.joyful,
      intentions: ['Pelo amor ao próximo', 'Pela caridade'],
    ),
    Mystery(
      id: 'joyful_3',
      title: '3º Mistério Gozoso',
      description:
          'O Nascimento do Menino Jesus naquela pobre gruta, em Belém.',
      reflection: 'Jesus nasce pobre, ensinando-nos o valor da simplicidade.',
      type: MysteryType.joyful,
      intentions: ['Pela pobreza de espírito', 'Pelas famílias'],
    ),
    Mystery(
      id: 'joyful_4',
      title: '4º Mistério Gozoso',
      description:
          'A Apresentação do Menino Jesus no templo e o rito de purificação da Santíssima Virgem Maria.',
      reflection: 'José e Maria cumprem a Lei, oferecendo Jesus a Deus.',
      type: MysteryType.joyful,
      intentions: ['Pela obediência', 'Pelos consagrados'],
    ),
    Mystery(
      id: 'joyful_5',
      title: '5º Mistério Gozoso',
      description:
          'A Perda e o reencontro do Menino Jesus no templo, em meio aos doutores da Lei.',
      reflection:
          'Jesus nos ensina que devemos buscar sempre as coisas do Pai.',
      type: MysteryType.joyful,
      intentions: ['Pela sabedoria', 'Pelos jovens'],
    ),
  ];

  static const List<Mystery> _sorrowfulMysteries = [
    Mystery(
      id: 'sorrowful_1',
      title: '1º Mistério Doloroso',
      description: 'A agonia de Nosso Senhor Jesus Cristo.',
      reflection: 'Jesus suou sangue pela angústia de nossos pecados.',
      type: MysteryType.sorrowful,
      intentions: ['Pelos pecadores', 'Pela conversão'],
    ),
    Mystery(
      id: 'sorrowful_2',
      title: '2º Mistério Doloroso',
      description: 'A cruel flagelação de Jesus, atado à coluna.',
      reflection: 'Jesus é açoitado cruelmente para pagar nossos pecados.',
      type: MysteryType.sorrowful,
      intentions: ['Pela purificação', 'Pelos que sofrem'],
    ),
    Mystery(
      id: 'sorrowful_3',
      title: '3º Mistério Doloroso',
      description: 'A coroação de espinhos de Nosso Senhor Jesus Cristo.',
      reflection: 'Coroado com espinhos, Jesus é escarnecido como Rei.',
      type: MysteryType.sorrowful,
      intentions: ['Contra o orgulho', 'Pela humildade'],
    ),
    Mystery(
      id: 'sorrowful_4',
      title: '4º Mistério Doloroso',
      description:
          'Nosso Senhor Jesus Cristo carregando a pesadíssima cruz às costas, a caminho do Calvário.',
      reflection: 'Jesus carrega nossa cruz e nos ensina a carregar a nossa.',
      type: MysteryType.sorrowful,
      intentions: ['Pela paciência', 'Pelos aflitos'],
    ),
    Mystery(
      id: 'sorrowful_5',
      title: '5º Mistério Doloroso',
      description: 'A Crucifixão e morte de Nosso Senhor Jesus Cristo.',
      reflection: 'Jesus morre na cruz para nos dar a vida eterna.',
      type: MysteryType.sorrowful,
      intentions: ['Pela salvação', 'Pelos agonizantes'],
    ),
  ];

  static const List<Mystery> _gloriousMysteries = [
    Mystery(
      id: 'glorious_1',
      title: '1º Mistério Glorioso',
      description: 'A Ressurreição de Nosso Senhor Jesus Cristo.',
      reflection: 'Jesus venceu a morte e nos deu a esperança da vida eterna.',
      type: MysteryType.glorious,
      intentions: ['Pela fé', 'Pelos que perderam a esperança'],
    ),
    Mystery(
      id: 'glorious_2',
      title: '2º Mistério Glorioso',
      description: 'A Ascensão de Nosso Senhor Jesus Cristo ao Céu',
      reflection: 'Jesus sobe aos céus para preparar lugar para nós.',
      type: MysteryType.glorious,
      intentions: ['Pela esperança', 'Pelos que partiram'],
    ),
    Mystery(
      id: 'glorious_3',
      title: '3º Mistério Glorioso',
      description:
          'A Vinda do Espírito Santo sobre Nossa Senhora e os Apóstolos, reunidos no Cenáculo em Jerusalém.',
      reflection: 'O Espírito Santo desce sobre Maria e os Apóstolos.',
      type: MysteryType.glorious,
      intentions: ['Pelos dons do Espírito', 'Pela Igreja'],
    ),
    Mystery(
      id: 'glorious_4',
      title: '4º Mistério Glorioso',
      description: 'A Assunção de Gloriosa de Nossa Senhora ao Céu.',
      reflection: 'Maria é elevada ao céu em corpo e alma.',
      type: MysteryType.glorious,
      intentions: ['Pela pureza', 'Pela boa morte'],
    ),
    Mystery(
      id: 'glorious_5',
      title: '5º Mistério Glorioso',
      description: 'A Coroação de Nossa Senhora como Rainha do Céu e da terra.',
      reflection: 'Maria é coroada Rainha do céu e da terra.',
      type: MysteryType.glorious,
      intentions: ['Pela devoção mariana', 'Pela perseverança'],
    ),
  ];

  static const List<Mystery> _luminousMysteries = [
    Mystery(
      id: 'luminous_1',
      title: '1º Mistério Luminoso',
      description: 'O Batismo de Nosso Senhor Jesus Cristo.',
      reflection: 'Jesus se manifesta como Filho amado do Pai.',
      type: MysteryType.luminous,
      intentions: ['Pelos batizados', 'Pela renovação batismal'],
    ),
    Mystery(
      id: 'luminous_2',
      title: '2º Mistério Luminoso',
      description:
          'O milagre acontecido nas Bodas de Caná da Galileia por intercessão da Virgem Santíssima.',
      reflection:
          'Jesus realiza seu primeiro milagre pela intercessão de Maria.',
      type: MysteryType.luminous,
      intentions: ['Pelas famílias', 'Pelos matrimônios'],
    ),
    Mystery(
      id: 'luminous_3',
      title: '3º Mistério Luminoso',
      description: 'O anúncio do Reino dos Céus e o chamado à conversão.',
      reflection: 'Jesus anuncia o Reino e chama à conversão.',
      type: MysteryType.luminous,
      intentions: ['Pela evangelização', 'Pelos missionários'],
    ),
    Mystery(
      id: 'luminous_4',
      title: '4º Mistério Luminoso',
      description:
          'A Transfiguração de Nosso Senhor Jesus Cristo, no Monte Tabor.',
      reflection: 'Jesus revela sua glória divina aos discípulos.',
      type: MysteryType.luminous,
      intentions: ['Pela contemplação', 'Pelos contemplativos'],
    ),
    Mystery(
      id: 'luminous_5',
      title: '5º Mistério Luminoso',
      description: 'A Instituição do Santíssimo Sacramento da Eucaristia.',
      reflection: 'Jesus se dá como alimento para a vida eterna.',
      type: MysteryType.luminous,
      intentions: ['Pela Eucaristia', 'Pelos sacerdotes'],
    ),
  ];
}
