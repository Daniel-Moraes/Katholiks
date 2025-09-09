import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/rosary.dart';
import '../../services/rosary_service.dart';
import 'rosary_tutorial_screen.dart';
import '../../widgets/rosary_icon.dart';

enum RosaryType {
  santoTerco,
  santoRosario,
  divinaMisericordia,
  saoMiguelArcanjo,
  sagradoCoracao,
  santasChagas,
  saoJose,
}

class RosaryHomeScreen extends StatefulWidget {
  const RosaryHomeScreen({super.key});

  @override
  State<RosaryHomeScreen> createState() => _RosaryHomeScreenState();
}

class _RosaryHomeScreenState extends State<RosaryHomeScreen>
    with SingleTickerProviderStateMixin {
  final RosaryService _rosaryService = RosaryService.instance;
  late AnimationController _animationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _initializeService();
  }

  Future<void> _initializeService() async {
    await _rosaryService.initialize();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 15),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildDailyChallenge(),
              const SizedBox(height: 32),
              _buildRosaryOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: 'Voltar',
        ),
        Expanded(
          child: Text(
            'Orações do Terço',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildDailyChallenge() {
    return ListenableBuilder(
      listenable: _rosaryService,
      builder: (context, _) {
        final stats = _rosaryService.stats;
        final todayProgress = _getTodayProgress(stats);
        final isCompleted = todayProgress >= 1;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCompleted
                  ? [
                      AppColors.success.withOpacity(0.1),
                      AppColors.success.withOpacity(0.05)
                    ]
                  : [
                      AppColors.warning.withOpacity(0.1),
                      AppColors.warning.withOpacity(0.05)
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.today,
                      color:
                          isCompleted ? AppColors.success : AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted
                              ? 'Meta Diária Completada! 🎉'
                              : 'Meta Diária',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        Text(
                          isCompleted
                              ? 'Parabéns! Você já rezou hoje. Continue assim!'
                              : 'Reze pelo menos 1 terço hoje',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '+50 pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: todayProgress,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.warning),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(todayProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRosaryOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha sua Oração',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        _buildRosaryCard(
          RosaryType.santoTerco,
          'Santo Terço',
          'Oração tradicional do Rosário com os mistérios de hoje',
          Icons.circle_outlined,
          AppColors.primary,
          isAvailable: true,
          basePoints: 50,
          bonusPoints: 20,
        ),
        const SizedBox(height: 16),
        _buildRosaryCard(
          RosaryType.santoRosario,
          'Santo Rosário',
          'Rosário completo com todos os mistérios (20 dezenas)',
          Icons.lens,
          AppColors.success,
          isAvailable: true,
          basePoints: 200,
          bonusPoints: 50,
        ),
        const SizedBox(height: 16),
        _buildRosaryCard(
          RosaryType.divinaMisericordia,
          'Terço da Divina Misericórdia',
          'Oração revelada a Santa Faustina para a misericórdia divina',
          Icons.favorite,
          AppColors.error,
          isAvailable: true,
          basePoints: 40,
          bonusPoints: 15,
        ),
        const SizedBox(height: 16),
        _buildRosaryCard(
          RosaryType.saoMiguelArcanjo,
          'Terço de São Miguel Arcanjo',
          'Oração de proteção e batalha espiritual',
          Icons.security,
          AppColors.warning,
          isAvailable: true,
          basePoints: 35,
          bonusPoints: 10,
        ),
        const SizedBox(height: 16),
        _buildRosaryCard(
          RosaryType.sagradoCoracao,
          'Terço do Sagrado Coração',
          'Devoção ao Coração de Jesus com promessas especiais',
          Icons.favorite_border,
          Colors.red.shade400,
          isAvailable: true,
          basePoints: 45,
          bonusPoints: 15,
        ),
        const SizedBox(height: 16),
        _buildRosaryCard(
          RosaryType.santasChagas,
          'Terço das Santas Chagas',
          'Meditação sobre as feridas de Cristo na Paixão',
          Icons.add,
          Colors.brown.shade400,
          isAvailable: true,
          basePoints: 60,
          bonusPoints: 25,
        ),
        const SizedBox(height: 16),
        _buildRosaryCard(
          RosaryType.saoJose,
          'Terço de São José',
          'Oração ao pai adotivo de Jesus e patrono da Igreja',
          Icons.home_work,
          Colors.blue.shade600,
          isAvailable: true,
          basePoints: 35,
          bonusPoints: 10,
        ),
      ],
    );
  }

  Widget _buildRosaryCard(
    RosaryType type,
    String title,
    String description,
    IconData icon,
    Color color, {
    bool isAvailable = false,
    int basePoints = 0,
    int bonusPoints = 0,
  }) {
    return ListenableBuilder(
      listenable: _rosaryService,
      builder: (context, _) {
        final isActive = _rosaryService.isSessionActive;

        return InkWell(
          onTap: isAvailable
              ? () {
                  if (type == RosaryType.santoTerco) {
                    if (isActive) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RosaryTutorialScreen(),
                        ),
                      );
                    } else {
                      _startNewSession();
                    }
                  } else if (type == RosaryType.santoRosario) {
                    if (isActive) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RosaryTutorialScreen(),
                        ),
                      );
                    } else {
                      _startCompleteRosarySession();
                    }
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isAvailable && basePoints > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+$basePoints pts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return ListenableBuilder(
      listenable: _rosaryService,
      builder: (context, _) {
        if (_isLoading) {
          return _buildLoadingStats();
        }

        final stats = _rosaryService.stats;
        return Column(
          children: [
            // Barra de nível/progresso
            _buildLevelProgress(stats),
            const SizedBox(height: 20),
            // Cards de estatísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Rezados',
                    '${stats.totalRosariesCompleted}',
                    const RosaryIcon(size: 24, color: AppColors.success),
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Sequência',
                    '${stats.currentStreak} dias',
                    const Icon(Icons.local_fire_department,
                        size: 24, color: AppColors.warning),
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pontos',
                    '${stats.totalPoints}',
                    const Icon(Icons.stars, size: 24, color: AppColors.primary),
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLevelProgress(stats) {
    final currentLevel = _calculateLevel(stats.totalPoints);
    final pointsForCurrentLevel = _getPointsForLevel(currentLevel);
    final pointsForNextLevel = _getPointsForLevel(currentLevel + 1);
    final progressInLevel = stats.totalPoints - pointsForCurrentLevel;
    final pointsNeededForLevel = pointsForNextLevel - pointsForCurrentLevel;
    final progressPercentage =
        (progressInLevel / pointsNeededForLevel).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nível $currentLevel',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _getLevelTitle(currentLevel),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.totalPoints} pts',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso para Nível ${currentLevel + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '$progressInLevel / $pointsNeededForLevel pts',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return Row(
      children: [
        Expanded(child: _buildLoadingStatCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildLoadingStatCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildLoadingStatCard()),
      ],
    );
  }

  Widget _buildLoadingStatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Widget icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: icon,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _startNewSession({MysteryType? mysteryType}) async {
    try {
      await _rosaryService.startRosarySession(mysteryType: mysteryType);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RosaryTutorialScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar terço: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _startCompleteRosarySession() async {
    try {
      await _rosaryService.startCompleteRosarySession();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RosaryTutorialScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar rosário completo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Métodos de gamificação
  int _calculateLevel(int totalPoints) {
    if (totalPoints < 100) return 1;
    if (totalPoints < 300) return 2;
    if (totalPoints < 600) return 3;
    if (totalPoints < 1000) return 4;
    if (totalPoints < 1500) return 5;
    if (totalPoints < 2500) return 6;
    if (totalPoints < 4000) return 7;
    if (totalPoints < 6000) return 8;
    if (totalPoints < 10000) return 9;
    return 10;
  }

  int _getPointsForLevel(int level) {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 100;
      case 3:
        return 300;
      case 4:
        return 600;
      case 5:
        return 1000;
      case 6:
        return 1500;
      case 7:
        return 2500;
      case 8:
        return 4000;
      case 9:
        return 6000;
      case 10:
        return 10000;
      default:
        return 10000;
    }
  }

  String _getLevelTitle(int level) {
    switch (level) {
      case 1:
        return 'Iniciante na Fé';
      case 2:
        return 'Devoto em Formação';
      case 3:
        return 'Peregrino Dedicado';
      case 4:
        return 'Servo Fiel';
      case 5:
        return 'Discípulo Comprometido';
      case 6:
        return 'Evangelizador';
      case 7:
        return 'Missionário da Oração';
      case 8:
        return 'Santo Guerreiro';
      case 9:
        return 'Intercessor Poderoso';
      case 10:
        return 'Místico da Oração';
      default:
        return 'Máximo Nível Atingido';
    }
  }

  double _getTodayProgress(stats) {
    final today = DateTime.now();
    final lastPrayer = stats.lastPrayer;

    if (lastPrayer != null &&
        lastPrayer.year == today.year &&
        lastPrayer.month == today.month &&
        lastPrayer.day == today.day) {
      return 1.0; // Meta completada
    }

    return 0.0; // Meta não completada
  }
}
