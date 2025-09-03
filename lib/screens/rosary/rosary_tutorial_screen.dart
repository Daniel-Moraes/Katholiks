import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';
import '../../models/rosary.dart';
import '../../services/rosary_service.dart';
import '../../widgets/custom_button.dart';

class RosaryTutorialScreen extends StatefulWidget {
  const RosaryTutorialScreen({super.key});

  @override
  State<RosaryTutorialScreen> createState() => _RosaryTutorialScreenState();
}

class _RosaryTutorialScreenState extends State<RosaryTutorialScreen>
    with TickerProviderStateMixin {
  final RosaryService _rosaryService = RosaryService.instance;

  late AnimationController _progressController;
  late AnimationController _prayerController;
  late Animation<double> _progressAnimation;
  late Animation<double> _prayerAnimation;

  bool _isPlaying = false;
  bool _showReflection = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _prayerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _prayerAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _prayerController,
      curve: Curves.elasticOut,
    ));

    _prayerController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _prayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _rosaryService,
        builder: (context, _) {
          final session = _rosaryService.currentSession;
          if (session == null) {
            return _buildNoSessionView();
          }

          return Column(
            children: [
              _buildProgressIndicator(session),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCurrentMystery(session),
                      const SizedBox(height: 24),
                      _buildCurrentPrayer(session),
                      const SizedBox(height: 32),
                      _buildPrayerControls(session),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 📱 AppBar personalizada
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Santo Terço',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        ListenableBuilder(
          listenable: _rosaryService,
          builder: (context, _) {
            final session = _rosaryService.currentSession;
            if (session?.status == RosarySessionStatus.inProgress) {
              return IconButton(
                icon: const Icon(Icons.pause, color: Colors.white),
                onPressed: () {
                  _rosaryService.pauseSession();
                  _showPauseDialog();
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// 📊 Indicador de progresso
  Widget _buildProgressIndicator(RosarySession session) {
    final progress = session.completedPrayers / session.totalPrayers;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso: ${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${session.completedPrayers}/${session.totalPrayers}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress * _progressAnimation.value,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            _getProgressMessage(session),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔮 Mistério atual
  Widget _buildCurrentMystery(RosarySession session) {
    if (session.currentMystery >= session.mysteries.length) {
      return const SizedBox.shrink();
    }

    final mystery = session.mysteries[session.currentMystery];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _getMysteryColor(mystery.type).withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getMysteryColor(mystery.type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getMysteryIcon(mystery.type),
                    color: _getMysteryColor(mystery.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mystery.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        mystery.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showReflection
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: CustomButton(
                text: 'Ver Reflexão',
                onPressed: () => setState(() => _showReflection = true),
                backgroundColor: _getMysteryColor(mystery.type),
                icon: Icons.psychology,
              ),
              secondChild: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Reflexão',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mystery.reflection,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _showReflection = false),
                      child: const Text('Ocultar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🙏 Oração atual
  Widget _buildCurrentPrayer(RosarySession session) {
    final currentPrayerText = _getCurrentPrayerText(session);

    return AnimatedBuilder(
      animation: _prayerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _prayerAnimation.value,
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPrayerIcon(currentPrayerText),
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getPrayerTitle(currentPrayerText),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentPrayerText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎮 Controles da oração
  Widget _buildPrayerControls(RosarySession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                'Anterior',
                Icons.skip_previous,
                session.completedPrayers > 0 ? () => _previousPrayer() : null,
              ),
              _buildMainActionButton(session),
              _buildControlButton(
                'Próxima',
                Icons.skip_next,
                () => _nextPrayer(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                'Audio',
                _isPlaying ? Icons.volume_off : Icons.volume_up,
                () => setState(() => _isPlaying = !_isPlaying),
              ),
              _buildControlButton(
                'Pausar',
                Icons.pause,
                () {
                  _rosaryService.pauseSession();
                  _showPauseDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎯 Botão de controle
  Widget _buildControlButton(
      String label, IconData icon, VoidCallback? onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor:
                onPressed != null ? AppColors.surface : AppColors.textSecondary,
            elevation: 2,
          ),
          child: Icon(
            icon,
            color:
                onPressed != null ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onPressed != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 🚀 Botão principal
  Widget _buildMainActionButton(RosarySession session) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _nextPrayer,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: AppColors.primary,
            elevation: 4,
          ),
          child: const Icon(
            Icons.done,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rezei',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 🚫 Quando não há sessão ativa
  Widget _buildNoSessionView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma sessão ativa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Volte à tela inicial para começar um terço',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// ⏭️ Próxima oração
  Future<void> _nextPrayer() async {
    final completed = await _rosaryService.nextPrayer();

    // Animações de feedback
    _prayerController.reset();
    _prayerController.forward();
    _progressController.forward();

    // Feedback tátil
    HapticFeedback.lightImpact();

    if (completed && mounted) {
      _showCompletionDialog();
    }
  }

  /// ⏮️ Oração anterior (implementação futura)
  void _previousPrayer() {
    // TODO: Implementar volta para oração anterior
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  /// ⏸️ Dialog de pausa
  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terço Pausado'),
        content: const Text(
            'Sua oração foi pausada. Você pode continuar quando estiver pronto.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rosaryService.resumeSession();
            },
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  /// 🎉 Dialog de conclusão
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.success),
            SizedBox(width: 8),
            Text('Parabéns!'),
          ],
        ),
        content: const Text(
            'Você completou o Santo Terço! Que Nossa Senhora interceda por suas intenções.'),
        actions: [
          CustomButton(
            text: 'Finalizar',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            backgroundColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  /// 📝 Helpers para obter texto e ícones
  String _getCurrentPrayerText(RosarySession session) {
    // Lógica simplificada - em implementação real seria mais complexa
    final progress = session.completedPrayers;

    if (progress < 5) {
      return 'Creio em Deus Pai todo-poderoso, criador do céu e da terra...';
    } else if (progress % 12 == 5) {
      return 'Pai nosso que estais nos céus, santificado seja o vosso nome...';
    } else {
      return 'Ave Maria, cheia de graça, o Senhor é convosco...';
    }
  }

  String _getPrayerTitle(String prayerText) {
    if (prayerText.startsWith('Creio')) return 'Creio';
    if (prayerText.startsWith('Pai')) return 'Pai Nosso';
    if (prayerText.startsWith('Ave')) return 'Ave Maria';
    return 'Oração';
  }

  IconData _getPrayerIcon(String prayerText) {
    if (prayerText.startsWith('Creio')) return Icons.church;
    if (prayerText.startsWith('Pai')) return Icons.person;
    if (prayerText.startsWith('Ave')) return Icons.favorite;
    return Icons.auto_awesome;
  }

  String _getProgressMessage(RosarySession session) {
    final progress = session.completedPrayers / session.totalPrayers;
    if (progress < 0.2) return 'Começando com fé';
    if (progress < 0.5) return 'Continuando com devoção';
    if (progress < 0.8) return 'Quase terminando';
    return 'Finalizando com amor';
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
