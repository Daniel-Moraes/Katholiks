import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/rosary.dart';
import '../../services/rosary_service.dart';
import 'rosary_tutorial_screen.dart';
import '../../widgets/custom_button.dart';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
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

  /// 📱 Header com título e ícone
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
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Santo Terço',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Reze com devoção e ganhe recompensas espirituais',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 🌟 Mistério do dia
  Widget _buildTodaysMystery() {
    final todaysMystery = _rosaryService.getTodaysMystery();
    final mysteryName = _getMysteryName(todaysMystery);
    final mysteryIcon = _getMysteryIcon(todaysMystery);
    final mysteryColor = _getMysteryColor(todaysMystery);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                    const Text(
                      'Mistério de Hoje',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mysteryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
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
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 Estatísticas rápidas
  Widget _buildQuickStats() {
    return ListenableBuilder(
      listenable: _rosaryService,
      builder: (context, _) {
        final stats = _rosaryService.stats;
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Terços Rezados',
                '${stats.totalRosariesCompleted}',
                Icons.auto_awesome,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Sequência',
                '${stats.currentStreak} dias',
                Icons.local_fire_department,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Pontos',
                '${stats.totalPoints}',
                Icons.stars,
                AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 📈 Card de estatística
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
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
              // Continuar sessão existente
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RosaryTutorialScreen(),
                ),
              );
            } else {
              // Iniciar nova sessão
              _startNewSession();
            }
          },
          backgroundColor: isActive ? AppColors.success : AppColors.primary,
          icon: isActive ? Icons.play_arrow : Icons.auto_awesome,
        );
      },
    );
  }

  /// 🎭 Seletor de mistérios
  Widget _buildMysterySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolher Mistério',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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

  /// 🏷️ Chip de mistério
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

  /// 🏆 Conquistas recentes
  Widget _buildAchievements() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: AppColors.warning,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Conquistas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Continue rezando para desbloquear conquistas especiais!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
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

  /// 🚀 Iniciar nova sessão
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

  /// 🎭 Helper: Nome do mistério
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

  /// 🎨 Helper: Cor do mistério
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

  /// 🎯 Helper: Ícone do mistério
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

  /// 📝 Helper: Descrição do mistério
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
