import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/rosary.dart';
import '../../services/rosary_service.dart';

class RosaryTutorialScreen extends StatefulWidget {
  const RosaryTutorialScreen({super.key});

  @override
  State<RosaryTutorialScreen> createState() => _RosaryTutorialScreenState();
}

class _RosaryTutorialScreenState extends State<RosaryTutorialScreen> {
  final RosaryService _rosaryService = RosaryService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListenableBuilder(
        listenable: _rosaryService,
        builder: (context, _) {
          final session = _rosaryService.currentSession;
          if (session == null) {
            return _buildNoSessionView();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com nome do mistério
                  _buildHeader(session),
                  const SizedBox(height: 20),

                  // Card do mistério específico com progresso
                  _buildCurrentMysteryCard(session),
                  const SizedBox(height: 20),

                  // Oração atual (removido o título separado)
                  // Texto da oração com título incluído
                  Expanded(
                    child: _buildPrayerText(session),
                  ),

                  // Botão principal
                  _buildMainActionButton(session),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📱 Header com botões e nome do mistério
  Widget _buildHeader(RosarySession session) {
    return Column(
      children: [
        // Botões de navegação com nome do mistério
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _getMysteryDisplayName(session.mysteryType),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.pause,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () {
                  _rosaryService.pauseSession();
                  _showPauseDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔮 Card do mistério específico com progresso
  Widget _buildCurrentMysteryCard(RosarySession session) {
    final progress = session.completedPrayers / session.totalPrayers;
    final progressPercent = (progress * 100).toInt();

    // Sempre mostrar o card de progresso, mesmo quando não estiver em um mistério
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getMysteryColor(session.mysteryType).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getMysteryColor(session.mysteryType).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header com progresso geral
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      _getMysteryColor(session.mysteryType).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        _getMysteryColor(session.mysteryType).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getCurrentMysteryTitle(session),
                  style: TextStyle(
                    color: _getMysteryColor(session.mysteryType),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      _getMysteryColor(session.mysteryType).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        _getMysteryColor(session.mysteryType).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$progressPercent%',
                  style: TextStyle(
                    color: _getMysteryColor(session.mysteryType),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Descrição do mistério atual (se disponível)
          if (_getCurrentMysteryDescription(session).isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMysteryColor(session.mysteryType).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getMysteryColor(session.mysteryType).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                _getCurrentMysteryDescription(session),
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Verificar se está em um mistério para mostrar progresso específico
          if (_getCurrentStep(session)?.isInMystery == true &&
              _getCurrentStep(session)?.currentMystery != null) ...[
            _buildMysterySpecificProgress(session),
            const SizedBox(height: 12),
          ],

          // Barra de progresso geral (sempre mostrar)
          _buildGeneralProgress(session),
        ],
      ),
    );
  }

  /// Progresso específico do mistério
  Widget _buildMysterySpecificProgress(RosarySession session) {
    final currentStep = _getCurrentStep(session)!;
    final mysteryNumber = currentStep.mysteryIndex + 1;

    // Contar apenas as Ave Marias no mistério atual
    final aveMariasInMystery = _countAveMariasInCurrentMystery(session);
    final mysteryProgress = aveMariasInMystery / 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$mysteryNumberº Mistério:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$aveMariasInMystery/10 Ave-Marias',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Barra de progresso com background fixo
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: mysteryProgress,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getMysteryColor(session.mysteryType),
                    _getMysteryColor(session.mysteryType).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color:
                        _getMysteryColor(session.mysteryType).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Progresso geral do terço
  Widget _buildGeneralProgress(RosarySession session) {
    final progress = session.completedPrayers / session.totalPrayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Progresso Geral:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${session.completedPrayers} de ${session.totalPrayers} orações',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        // Barra de progresso geral com background fixo
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getMysteryColor(session.mysteryType).withOpacity(0.7),
                    _getMysteryColor(session.mysteryType).withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerText(RosarySession session) {
    final currentPrayerText = _getCurrentPrayerText(session);

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _getMysteryColor(session.mysteryType).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Título da oração em negrito
            Text(
              _getPrayerTitle(session),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Texto da oração
            Text(
              currentPrayerText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 17,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// � Botão principal de ação
  /// 🎯 Botão principal de ação
  Widget _buildMainActionButton(RosarySession session) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMysteryColor(session.mysteryType),
            _getMysteryColor(session.mysteryType).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _getMysteryColor(session.mysteryType).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextPrayer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Rezei',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSessionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma sessão ativa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Volte à tela inicial para começar um terço',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 Métodos auxiliares
  String _getMysteryDisplayName(MysteryType type) {
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

  RosaryPrayerStep? _getCurrentStep(RosarySession session) {
    if (session.prayerSteps.isEmpty ||
        session.completedPrayers >= session.prayerSteps.length) {
      return null;
    }
    return session.prayerSteps[session.completedPrayers];
  }

  Future<void> _nextPrayer() async {
    final completed = await _rosaryService.nextPrayer();

    // Feedback tátil
    HapticFeedback.lightImpact();

    if (completed && mounted) {
      _showCompletionDialog();
    }
  }

  /// ⏸️ Dialog de pausa
  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Terço Pausado',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Sua oração foi pausada. Você pode continuar quando estiver pronto.',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber),
            const SizedBox(width: 8),
            Text('Parabéns!',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        content: Text(
          'Você completou o Santo Terço! Que Nossa Senhora interceda por suas intenções.',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text(
              'Finalizar',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentPrayerText(RosarySession session) {
    if (session.prayerSteps.isNotEmpty &&
        session.completedPrayers < session.prayerSteps.length) {
      final currentStep = session.prayerSteps[session.completedPrayers];
      return currentStep.type.text;
    }
    return PrayerTypeExpanded.aveMaria.text;
  }

  String _getPrayerTitle(RosarySession session) {
    if (session.prayerSteps.isNotEmpty &&
        session.completedPrayers < session.prayerSteps.length) {
      final currentStep = session.prayerSteps[session.completedPrayers];
      return currentStep.type.title;
    }
    return 'Ave Maria';
  }

  Color _getMysteryColor(MysteryType type) {
    // Usando as cores do tema do app para todos os mistérios
    return Theme.of(context).colorScheme.primary;
  }

  /// 📖 Obter descrição do mistério atual
  String _getCurrentMysteryDescription(RosarySession session) {
    final currentStep = _getCurrentStep(session);
    if (currentStep?.currentMystery != null) {
      return currentStep!.currentMystery!.description;
    }
    return '';
  }

  /// � Obter título do mistério atual
  String _getCurrentMysteryTitle(RosarySession session) {
    final currentStep = _getCurrentStep(session);
    if (currentStep?.currentMystery != null) {
      return currentStep!.currentMystery!.title;
    }
    // Fallback para o nome genérico do tipo de mistério
    return _getMysteryDisplayName(session.mysteryType);
  }

  /// �📿 Contar apenas as Ave Marias no mistério atual
  int _countAveMariasInCurrentMystery(RosarySession session) {
    final currentStep = _getCurrentStep(session);
    if (currentStep == null || !currentStep.isInMystery) {
      return 0;
    }

    int aveMariaCount = 0;
    final currentMysteryIndex = currentStep.mysteryIndex;

    // Contar apenas as Ave Marias já completadas no mistério atual
    for (int i = 0; i < session.completedPrayers; i++) {
      final step = session.prayerSteps[i];
      if (step.mysteryIndex == currentMysteryIndex &&
          step.type == PrayerTypeExpanded.aveMaria) {
        aveMariaCount++;
      }
    }

    // Se a oração atual for Ave Maria e estivermos no mesmo mistério, incluir
    if (session.completedPrayers < session.prayerSteps.length) {
      final currentPrayerStep = session.prayerSteps[session.completedPrayers];
      if (currentPrayerStep.mysteryIndex == currentMysteryIndex &&
          currentPrayerStep.type == PrayerTypeExpanded.aveMaria) {
        aveMariaCount++;
      }
    }

    return aveMariaCount;
  }
}
