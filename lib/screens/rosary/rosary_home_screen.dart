import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/rosary.dart';
import '../../services/rosary_service.dart';
import 'rosary_tutorial_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/rosary_icon.dart';

class RosaryHomeScreen extends StatefulWidget {
  const RosaryHomeScreen({super.key});

  @override
  State<RosaryHomeScreen> createState() => _RosaryHomeScreenState();
}

class _RosaryHomeScreenState extends State<RosaryHomeScreen>
    with SingleTickerProviderStateMixin {
  final RosaryService _rosaryService = RosaryService.instance;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Inicializar o RosaryService para carregar as estatísticas
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
      body: Container(
        decoration: Theme.of(context).brightness == Brightness.dark
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkBackground,
                    AppColors.darkSurface,
                  ],
                ),
              )
            : null,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildTodaysMystery(),
                const SizedBox(height: 32),
                _buildQuickStats(),
                const SizedBox(height: 32),
                _buildStartButton(),
                const SizedBox(height: 24),
                _buildMysterySelector(),
                const SizedBox(height: 32),
                _buildAchievements(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.15)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: RosaryIcon(
                  size: 60,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Santo Terço',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkOnBackground
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Reze com devoção e ganhe recompensas espirituais',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkOnBackground.withOpacity(0.9)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTodaysMystery() {
    final todaysMystery = _rosaryService.getTodaysMystery();
    final mysteryName = _getMysteryName(todaysMystery);
    final mysteryIcon = _getMysteryIcon(todaysMystery);
    final mysteryColor = _getMysteryColor(todaysMystery);

    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mysteryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  mysteryIcon,
                  color: mysteryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mistério de Hoje',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mysteryName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getMysteryDescription(todaysMystery),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
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
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Rezados',
                '${stats.totalRosariesCompleted}',
                const RosaryIcon(size: 24, color: AppColors.success),
                AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Sequência',
                '${stats.currentStreak} dias',
                const Icon(Icons.local_fire_department,
                    size: 24, color: AppColors.warning),
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Pontos',
                '${stats.totalPoints}',
                const Icon(Icons.stars, size: 24, color: AppColors.primary),
                AppColors.primary,
              ),
            ),
          ],
        );
      },
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

  /// 🚀 Botão para iniciar
  Widget _buildStartButton() {
    return ListenableBuilder(
      listenable: _rosaryService,
      builder: (context, _) {
        final isActive = _rosaryService.isSessionActive;

        return CustomButton(
          text: isActive ? 'Continuar Terço' : 'Iniciar Terço',
          onPressed: () {
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
          },
        );
      },
    );
  }

  Widget _buildMysterySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escolher Mistério',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MysteryType.values.map((type) {
              return _buildMysteryChip(type);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMysteryChip(MysteryType type) {
    final name = _getMysteryName(type);
    final color = _getMysteryColor(type);

    return GestureDetector(
      onTap: () => _startNewSession(mysteryType: type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getMysteryIcon(type),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Conquistas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Continue rezando para desbloquear conquistas especiais!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Ver Todas as Conquistas',
            onPressed: () {
              // Navegar para tela de conquistas
            },
            backgroundColor: AppColors.warning,
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

  String _getMysteryDescription(MysteryType type) {
    switch (type) {
      case MysteryType.joyful:
        return 'Contemplamos os momentos de alegria da vida de Jesus e Maria.';
      case MysteryType.sorrowful:
        return 'Meditamos sobre o sofrimento redentor de Nosso Senhor.';
      case MysteryType.glorious:
        return 'Celebramos a vitória de Cristo sobre a morte e o pecado.';
      case MysteryType.luminous:
        return 'Refletimos sobre os momentos de luz no ministério de Jesus.';
    }
  }
}
