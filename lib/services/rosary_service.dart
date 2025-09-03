import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/rosary.dart';
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

  // Getters
  RosarySession? get currentSession => _currentSession;
  RosaryStats get stats => _stats;
  bool get isSessionActive =>
      _currentSession?.status == RosarySessionStatus.inProgress;

  Future<void> initialize() async {
    try {
      final savedStats = await _firestoreService.loadUserStats();
      if (savedStats != null) {
        _stats = savedStats;
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao inicializar RosaryService: $e');
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

  Future<RosarySession> startRosarySession({MysteryType? mysteryType}) async {
    final selectedMystery = mysteryType ?? getTodaysMystery();
    final mysteries = _getMysteries(selectedMystery);

    _currentSession = RosarySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      mysteryType: selectedMystery,
      mysteries: mysteries,
      currentMystery: 0,
      currentDecade: 0,
      currentPrayer: 0,
      totalPrayers: _calculateTotalPrayers(),
      completedPrayers: 0,
      achievedMilestones: [],
      status: RosarySessionStatus.inProgress,
      prayerCounts: {},
    );

    HapticFeedback.lightImpact();

    notifyListeners();
    return _currentSession!;
  }

  void pauseSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: RosarySessionStatus.paused,
      );
      notifyListeners();
    }
  }

  void resumeSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: RosarySessionStatus.inProgress,
      );
      notifyListeners();
    }
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
    notifyListeners();
    return false;
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

    _currentSession = completedSession.copyWith(
      achievedMilestones: achievements,
    );

    try {
      await _firestoreService.saveRosarySession(_currentSession!);
      await _firestoreService.saveUserStats(_stats);

      for (final achievement in achievements) {
        await _firestoreService.saveAchievement(achievement);
      }
    } catch (e) {
      print('Erro ao salvar sessão no Firebase: $e');
    }

    notifyListeners();
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

  int _calculateTotalPrayers() {
    return 53; // 1 Creio + 1 Pai Nosso + 3 Ave + 5x(1 Pai Nosso + 10 Ave + 1 Glória) + orações finais
  }

  void _updateCurrentPosition(RosarySession session) {
    final progress = session.completedPrayers;

    if (progress < 5) {
      // Orações iniciais
    } else if (progress < 55) {
      // Dezenas dos mistérios
      final decadeProgress = (progress - 5) ~/ 12;
      session.copyWith(
        currentMystery: decadeProgress.clamp(0, 4),
        currentDecade: decadeProgress.clamp(0, 4),
      );
    } else {
      // Orações finais
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
      description: 'A Anunciação do Anjo à Nossa Senhora',
      reflection:
          'Contemplemos a humildade de Maria ao aceitar ser a Mãe de Deus.',
      type: MysteryType.joyful,
      intentions: ['Pela humildade', 'Pelas vocações religiosas'],
    ),
    // ... outros mistérios
  ];

  static const List<Mystery> _sorrowfulMysteries = [
    Mystery(
      id: 'sorrowful_1',
      title: '1º Mistério Doloroso',
      description: 'A Agonia de Jesus no Horto',
      reflection: 'Jesus suou sangue pela angústia de nossos pecados.',
      type: MysteryType.sorrowful,
      intentions: ['Pelos pecadores', 'Pela conversão'],
    ),
    // ... outros mistérios
  ];

  static const List<Mystery> _gloriousMysteries = [
    Mystery(
      id: 'glorious_1',
      title: '1º Mistério Glorioso',
      description: 'A Ressurreição de Jesus',
      reflection: 'Jesus venceu a morte e nos deu a esperança da vida eterna.',
      type: MysteryType.glorious,
      intentions: ['Pela fé', 'Pelos que perderam a esperança'],
    ),
    // ... outros mistérios
  ];

  static const List<Mystery> _luminousMysteries = [
    Mystery(
      id: 'luminous_1',
      title: '1º Mistério Luminoso',
      description: 'O Batismo de Jesus no Jordão',
      reflection: 'Jesus se manifesta como Filho amado do Pai.',
      type: MysteryType.luminous,
      intentions: ['Pelos batizados', 'Pela renovação batismal'],
    ),
    // ... outros mistérios
  ];
}
