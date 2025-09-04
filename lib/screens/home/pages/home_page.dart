import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:katholiks/utils/app_colors.dart';
import '../../../widgets/rosary_icon.dart';
import '../../../services/rosary_service.dart';
import '../../../models/rosary.dart';

class GamifiedHomePage extends StatefulWidget {
  final Animation<double> pulseAnimation;
  final Animation<double> streakAnimation;

  const GamifiedHomePage({
    super.key,
    required this.pulseAnimation,
    required this.streakAnimation,
  });

  @override
  State<GamifiedHomePage> createState() => _GamifiedHomePageState();
}

class _GamifiedHomePageState extends State<GamifiedHomePage> {
  final RosaryService _rosaryService = RosaryService.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              _buildUserLevel(context),
              _buildTodayChallenge(context),
              _buildQuickActions(context, size),
              _buildRecentAchievements(context),
              _buildDailyProgress(context),
              _buildCommunityHighlights(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTextColor(BuildContext context, {bool isPrimary = true}) {
    if (isPrimary) {
      return Theme.of(context).colorScheme.onBackground;
    } else {
      return Theme.of(context).colorScheme.onBackground.withOpacity(0.7);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Boa madrugada';
    String subtitle = 'Que Deus abençoe seu dia';
    IconData greetingIcon = Icons.nights_stay;

    if (hour >= 5 && hour < 12) {
      greeting = 'Bom dia';
      subtitle = 'Que a paz de Cristo esteja contigo';
      greetingIcon = Icons.wb_sunny;
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Boa tarde';
      subtitle = 'Continue sua jornada espiritual';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour >= 18) {
      greeting = 'Boa noite';
      subtitle = 'Momento ideal para oração';
      greetingIcon = Icons.nightlight_round;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  greetingIcon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: _getTextColor(context, isPrimary: false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserLevel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ListenableBuilder(
        listenable: _rosaryService,
        builder: (context, _) {
          final stats = _rosaryService.stats;
          final level = _getUserLevel(stats.totalPoints);
          final progress = _getLevelProgress(stats.totalPoints);

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: widget.pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: widget.pulseAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: _getLevelGradient(level),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getLevelIcon(level),
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLevelName(level),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(context),
                            ),
                          ),
                          Text(
                            '${stats.totalPoints} pontos',
                            style: TextStyle(
                              fontSize: 14,
                              color: _getTextColor(context, isPrimary: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: widget.streakAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${stats.currentStreak}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso para ${_getLevelName(level + 1)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: _getLevelGradient(level),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayChallenge(BuildContext context) {
    final todaysMystery = _rosaryService.getTodaysMystery();
    final mysteryName = _getMysteryName(todaysMystery);
    final mysteryColor = _getMysteryColor(todaysMystery);
    final mysteryIcon = _getMysteryIcon(todaysMystery);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2D2D)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mysteryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  mysteryIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 Desafio de Hoje',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(context),
                      ),
                    ),
                    Text(
                      mysteryName,
                      style: TextStyle(
                        fontSize: 14,
                        color: mysteryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: mysteryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '+100 XP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mysteryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reze o Terço Mariano',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mysteryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete os 5 mistérios de hoje e ganhe pontos especiais',
                  style: TextStyle(
                    fontSize: 14,
                    color: mysteryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/rosary'),
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: mysteryColor,
                  //   foregroundColor: Colors.white,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  // ),
                  child: const Text('Começar Agora'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ Ações Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                title: 'Terço Mariano',
                subtitle: 'Oração diária',
                icon: const RosaryIcon(size: 32, color: Colors.white),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                onTap: () => context.push('/rosary'),
              ),
              _buildActionCard(
                title: 'Santo Rosário',
                subtitle: '20 mistérios',
                icon: const Icon(Icons.auto_awesome,
                    size: 32, color: Colors.white),
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.7)
                  ],
                ),
                onTap: () {},
              ),
              _buildActionCard(
                title: 'Orações',
                subtitle: 'Biblioteca completa',
                icon:
                    const Icon(Icons.menu_book, size: 32, color: Colors.white),
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning,
                    AppColors.warning.withOpacity(0.7)
                  ],
                ),
                onTap: () {},
              ),
              _buildActionCard(
                title: 'Bíblia',
                subtitle: '73 livros católicos',
                icon: const Icon(Icons.book, size: 32, color: Colors.white),
                gradient: LinearGradient(
                  colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required Widget icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 Conquistas Recentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Primeiro\nTerço',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ListenableBuilder(
        listenable: _rosaryService,
        builder: (context, _) {
          final stats = _rosaryService.stats;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 Progresso Diário',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          icon: const RosaryIcon(
                              size: 24, color: AppColors.success),
                          value: '${stats.totalRosariesCompleted}',
                          label: 'Terços\nRezados',
                          color: AppColors.success,
                        ),
                        _buildStatItem(
                          icon: const Icon(Icons.local_fire_department,
                              size: 24, color: AppColors.warning),
                          value: '${stats.currentStreak}',
                          label: 'Dias\nSeguidos',
                          color: AppColors.warning,
                        ),
                        _buildStatItem(
                          icon: const Icon(Icons.stars,
                              size: 24, color: AppColors.primary),
                          value: '${stats.totalPoints}',
                          label: 'Pontos\nTotais',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required Widget icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: icon),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCommunityHighlights(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 Destaques da Comunidade',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.groups, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Junte-se à Comunidade',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Compartilhe sua jornada espiritual',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '🌟 Mais de 1.000 devotos rezando juntos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: Colors.white,
                      //   foregroundColor: AppColors.primary,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      // ),
                      child: const Text('Participar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getUserLevel(int points) {
    if (points < 500) return 1;
    if (points < 2000) return 2;
    if (points < 5000) return 3;
    if (points < 10000) return 4;
    return 5;
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return '🌱 Iniciante';
      case 2:
        return '🙏 Devoto';
      case 3:
        return '⭐ Fiel';
      case 4:
        return '👑 Servo';
      case 5:
        return '✨ Santo';
      default:
        return '✨ Santo';
    }
  }

  IconData _getLevelIcon(int level) {
    switch (level) {
      case 1:
        return Icons.eco;
      case 2:
        return Icons.favorite;
      case 3:
        return Icons.star;
      case 4:
        return Icons.military_tech;
      case 5:
        return Icons.auto_awesome;
      default:
        return Icons.auto_awesome;
    }
  }

  Gradient _getLevelGradient(int level) {
    switch (level) {
      case 1:
        return const LinearGradient(colors: [Colors.green, Colors.lightGreen]);
      case 2:
        return const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary]);
      case 3:
        return const LinearGradient(colors: [AppColors.warning, Colors.amber]);
      case 4:
        return const LinearGradient(colors: [Colors.purple, Colors.deepPurple]);
      case 5:
        return const LinearGradient(colors: [Colors.amber, Colors.orange]);
      default:
        return const LinearGradient(colors: [Colors.amber, Colors.orange]);
    }
  }

  double _getLevelProgress(int points) {
    final level = _getUserLevel(points);
    switch (level) {
      case 1:
        return points / 500.0;
      case 2:
        return (points - 500) / 1500.0;
      case 3:
        return (points - 2000) / 3000.0;
      case 4:
        return (points - 5000) / 5000.0;
      case 5:
        return 1.0;
      default:
        return 1.0;
    }
  }

  String _getMysteryName(MysteryType type) {
    switch (type) {
      case MysteryType.joyful:
        return 'Mistérios Gozosos';
      case MysteryType.sorrowful:
        return 'Mistérios Dolorosos';
      case MysteryType.glorious:
        return 'Mistérios Gloriosos';
      case MysteryType.luminous:
        return 'Mistérios Luminosos';
    }
  }

  Color _getMysteryColor(MysteryType type) {
    switch (type) {
      case MysteryType.joyful:
        return AppColors.success;
      case MysteryType.sorrowful:
        return AppColors.error;
      case MysteryType.glorious:
        return AppColors.warning;
      case MysteryType.luminous:
        return AppColors.primary;
    }
  }

  IconData _getMysteryIcon(MysteryType type) {
    switch (type) {
      case MysteryType.joyful:
        return Icons.child_friendly;
      case MysteryType.sorrowful:
        return Icons.favorite;
      case MysteryType.glorious:
        return Icons.wb_sunny;
      case MysteryType.luminous:
        return Icons.lightbulb;
    }
  }
}
