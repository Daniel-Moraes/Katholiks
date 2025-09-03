import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rosary.dart';

class RosaryFirestoreService {
  static final RosaryFirestoreService _instance =
      RosaryFirestoreService._internal();
  factory RosaryFirestoreService() => _instance;
  RosaryFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<void> saveUserStats(RosaryStats stats) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('rosary_stats')
        .doc('current')
        .set({
      'totalRosariesCompleted': stats.totalRosariesCompleted,
      'currentStreak': stats.currentStreak,
      'longestStreak': stats.longestStreak,
      'totalPrayerTime': stats.totalPrayerTime.inSeconds,
      'mysteriesCompleted': stats.mysteriesCompleted.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'totalAchievements': stats.totalAchievements,
      'totalPoints': stats.totalPoints,
      'lastPrayer': stats.lastPrayer != null
          ? Timestamp.fromDate(stats.lastPrayer!)
          : null,
      'averageSessionDuration': stats.averageSessionDuration,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<RosaryStats?> loadUserStats() async {
    if (_currentUserId == null) {
      print(
          'RosaryFirestoreService: Usuário não logado, não é possível carregar estatísticas');
      return null;
    }

    try {
      print(
          'RosaryFirestoreService: Carregando estatísticas para usuário: $_currentUserId');
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('rosary_stats')
          .doc('current')
          .get();

      if (doc.exists) {
        print('RosaryFirestoreService: Estatísticas encontradas no Firestore');
        final data = doc.data()!;
        return RosaryStats(
          totalRosariesCompleted: data['totalRosariesCompleted'] ?? 0,
          currentStreak: data['currentStreak'] ?? 0,
          longestStreak: data['longestStreak'] ?? 0,
          totalPrayerTime: Duration(seconds: data['totalPrayerTime'] ?? 0),
          mysteriesCompleted:
              (data['mysteriesCompleted'] as Map<String, dynamic>?)
                      ?.map((key, value) => MapEntry(
                            MysteryType.values.firstWhere(
                              (e) => e.name == key,
                              orElse: () => MysteryType.joyful,
                            ),
                            value as int,
                          )) ??
                  {},
          dailyGoals: const {},
          totalAchievements: data['totalAchievements'] ?? 0,
          totalPoints: data['totalPoints'] ?? 0,
          lastPrayer: data['lastPrayer'] != null
              ? (data['lastPrayer'] as Timestamp).toDate()
              : null,
          averageSessionDuration:
              (data['averageSessionDuration'] ?? 0).toDouble(),
        );
      } else {
        print(
            'RosaryFirestoreService: Nenhuma estatística encontrada no Firestore');
      }
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
    }

    return null;
  }

  Future<RosaryStats> createInitialStats() async {
    if (_currentUserId == null) {
      return const RosaryStats(
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
    }

    print(
        'RosaryFirestoreService: Criando estatísticas iniciais para usuário: $_currentUserId');
    final initialStats = RosaryStats(
      totalRosariesCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalPrayerTime: const Duration(seconds: 0),
      mysteriesCompleted: {
        MysteryType.joyful: 0,
        MysteryType.sorrowful: 0,
        MysteryType.glorious: 0,
        MysteryType.luminous: 0,
      },
      dailyGoals: {},
      totalAchievements: 0,
      totalPoints: 0,
      lastPrayer: null,
      averageSessionDuration: 0,
    );

    // Salvar estatísticas iniciais no Firestore
    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('rosary_stats')
        .doc('current')
        .set({
      'totalRosariesCompleted': initialStats.totalRosariesCompleted,
      'currentStreak': initialStats.currentStreak,
      'longestStreak': initialStats.longestStreak,
      'totalPrayerTime': initialStats.totalPrayerTime.inSeconds,
      'mysteriesCompleted': initialStats.mysteriesCompleted
          .map((key, value) => MapEntry(key.name, value)),
      'totalAchievements': initialStats.totalAchievements,
      'totalPoints': initialStats.totalPoints,
      'lastPrayer': initialStats.lastPrayer,
      'averageSessionDuration': initialStats.averageSessionDuration,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return initialStats;
  }

  Future<void> saveRosarySession(RosarySession session) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('rosary_sessions')
        .doc(session.id)
        .set({
      'id': session.id,
      'startTime': Timestamp.fromDate(session.startTime),
      'endTime':
          session.endTime != null ? Timestamp.fromDate(session.endTime!) : null,
      'mysteryType': session.mysteryType.name,
      'currentMystery': session.currentMystery,
      'currentDecade': session.currentDecade,
      'currentPrayer': session.currentPrayer,
      'totalPrayers': session.totalPrayers,
      'completedPrayers': session.completedPrayers,
      'status': session.status.name,
      'achievedMilestones': session.achievedMilestones
          .map((a) => {
                'id': a.id,
                'title': a.title,
                'description': a.description,
                'type': a.type.name,
                'points': a.points,
                'unlockedAt': Timestamp.fromDate(a.unlockedAt),
              })
          .toList(),
      'prayerCounts': session.prayerCounts.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'createdAt': Timestamp.now(),
    });
  }

  Future<List<RosarySession>> loadUserSessions({int limit = 10}) async {
    if (_currentUserId == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('rosary_sessions')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return RosarySession(
              id: data['id'],
              startTime: (data['startTime'] as Timestamp).toDate(),
              endTime: data['endTime'] != null
                  ? (data['endTime'] as Timestamp).toDate()
                  : null,
              mysteryType: MysteryType.values.firstWhere(
                (e) => e.name == data['mysteryType'],
                orElse: () => MysteryType.joyful,
              ),
              mysteries: const [],
              prayerSteps: const [],
              currentMystery: data['currentMystery'] ?? 0,
              currentDecade: data['currentDecade'] ?? 0,
              currentPrayer: data['currentPrayer'] ?? 0,
              totalPrayers: data['totalPrayers'] ?? 0,
              completedPrayers: data['completedPrayers'] ?? 0,
              status: RosarySessionStatus.values.firstWhere(
                (e) => e.name == data['status'],
                orElse: () => RosarySessionStatus.completed,
              ),
              achievedMilestones: (data['achievedMilestones'] as List<dynamic>?)
                      ?.map((item) => Achievement(
                            id: item['id'],
                            title: item['title'],
                            description: item['description'],
                            iconName: '', // Será definido pelo tipo
                            type: AchievementType.values.firstWhere(
                              (e) => e.name == item['type'],
                              orElse: () => AchievementType.firstRosary,
                            ),
                            requiredCount: 1,
                            points: item['points'] ?? 0,
                            unlockedAt: item['unlockedAt'] != null
                                ? (item['unlockedAt'] as Timestamp).toDate()
                                : DateTime.now(),
                          ))
                      .toList() ??
                  [],
              prayerCounts: {},
            );
          })
          .toList()
          .cast<RosarySession>();
    } catch (e) {
      print('Erro ao carregar sessões: $e');
      return [];
    }
  }

  Future<void> saveAchievement(Achievement achievement) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('achievements')
        .doc(achievement.id)
        .set({
      'id': achievement.id,
      'title': achievement.title,
      'description': achievement.description,
      'iconName': achievement.iconName,
      'type': achievement.type.name,
      'requiredCount': achievement.requiredCount,
      'points': achievement.points,
      'unlockedAt': Timestamp.fromDate(achievement.unlockedAt),
      'createdAt': Timestamp.now(),
    });
  }

  Future<List<Achievement>> loadUserAchievements() async {
    if (_currentUserId == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('achievements')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Achievement(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          iconName: data['iconName'],
          type: AchievementType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => AchievementType.firstRosary,
          ),
          requiredCount: data['requiredCount'] ?? 1,
          points: data['points'] ?? 0,
          unlockedAt: data['unlockedAt'] != null
              ? (data['unlockedAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar conquistas: $e');
      return [];
    }
  }

  Stream<RosaryStats?> watchUserStats() {
    if (_currentUserId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('rosary_stats')
        .doc('current')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        return RosaryStats(
          totalRosariesCompleted: data['totalRosariesCompleted'] ?? 0,
          currentStreak: data['currentStreak'] ?? 0,
          longestStreak: data['longestStreak'] ?? 0,
          totalPrayerTime: Duration(seconds: data['totalPrayerTime'] ?? 0),
          mysteriesCompleted:
              (data['mysteriesCompleted'] as Map<String, dynamic>?)
                      ?.map((key, value) => MapEntry(
                            MysteryType.values.firstWhere(
                              (e) => e.name == key,
                              orElse: () => MysteryType.joyful,
                            ),
                            value as int,
                          )) ??
                  {},
          dailyGoals: const {},
          totalAchievements: data['totalAchievements'] ?? 0,
          totalPoints: data['totalPoints'] ?? 0,
          lastPrayer: data['lastPrayer'] != null
              ? (data['lastPrayer'] as Timestamp).toDate()
              : null,
          averageSessionDuration:
              (data['averageSessionDuration'] ?? 0).toDouble(),
        );
      }
      return null;
    });
  }
}
