import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/rosary.dart';
import '../../services/rosary_service.dart';
import '../../services/simple_audio_service.dart';

class RosaryTutorialScreen extends StatefulWidget {
  const RosaryTutorialScreen({super.key});

  @override
  State<RosaryTutorialScreen> createState() => _RosaryTutorialScreenState();
}

class _RosaryTutorialScreenState extends State<RosaryTutorialScreen> {
  final RosaryService _rosaryService = RosaryService.instance;
  final SimpleAudioService _audioService = SimpleAudioService();
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  DateTime? _playStartTime;
  bool _wasPlayingLastCheck = false;
  bool _autoPlayEnabled = false;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_autoPlayEnabled &&
          mounted &&
          _rosaryService.currentSession != null) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted && _rosaryService.currentSession != null) {
          final prayerTitle = _getPrayerTitle(_rosaryService.currentSession!);
          await _playPrayerAudio(prayerTitle);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupAudioListeners() {
    _startProgressTimer();
  }

  void _startProgressTimer() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _updateAudioProgress();
        });
        _startProgressTimer();
      }
    });
  }

  void _updateAudioProgress() {
    final isCurrentlyPlaying = _audioService.isPlaying;

    if (isCurrentlyPlaying && !_wasPlayingLastCheck) {
      _playStartTime = DateTime.now();
      final prayerTitle = _rosaryService.currentSession != null
          ? _getPrayerTitle(_rosaryService.currentSession!)
          : 'Ave Maria';
      _audioDuration = _getPrayerDuration(prayerTitle);
    }

    if (!isCurrentlyPlaying && _wasPlayingLastCheck) {
      if (_audioPosition >= _audioDuration) {
        if (_autoPlayEnabled && _rosaryService.currentSession != null) {
          Future.delayed(const Duration(milliseconds: 800), () async {
            if (mounted) {
              await _nextPrayer();
            }
          });
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _audioPosition = Duration.zero;
                _playStartTime = null;
              });
            }
          });
        }
      } else {
        _playStartTime = null;
      }
    }

    if (isCurrentlyPlaying && _playStartTime != null) {
      final elapsed = DateTime.now().difference(_playStartTime!);
      _audioPosition = elapsed > _audioDuration ? _audioDuration : elapsed;

      if (_audioPosition >= _audioDuration) {
        _audioPosition = _audioDuration;
      }
    }

    _wasPlayingLastCheck = isCurrentlyPlaying;
  }

  Duration _getPrayerDuration(String prayerTitle) {
    switch (prayerTitle.toLowerCase()) {
      case 'ave maria':
        return const Duration(seconds: 19);
      case 'pai nosso':
        return const Duration(seconds: 31);
      case 'glória ao pai':
        return const Duration(seconds: 7);
      case 'sinal da cruz':
        return const Duration(seconds: 4);
      case 'creio em deus pai':
        return const Duration(seconds: 47);
      default:
        return const Duration(seconds: 19);
    }
  }

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
              padding: const EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(session),
                  const SizedBox(height: 20),
                  _buildCurrentMysteryCard(session),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildPrayerText(session),
                  ),
                  _buildBottomControlsSection(session),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(RosarySession session) {
    return Column(
      children: [
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
            const SizedBox(width: 48),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentMysteryCard(RosarySession session) {
    final progress = session.completedPrayers / session.totalPrayers;
    final progressPercent = (progress * 100).toInt();

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
          if (_getCurrentStep(session)?.isInMystery == true &&
              _getCurrentStep(session)?.currentMystery != null) ...[
            _buildMysterySpecificProgress(session),
            const SizedBox(height: 12),
          ],
          _buildGeneralProgress(session),
        ],
      ),
    );
  }

  Widget _buildMysterySpecificProgress(RosarySession session) {
    final currentStep = _getCurrentStep(session)!;
    final mysteryNumber = currentStep.mysteryIndex + 1;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getMysteryColor(session.mysteryType).withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              _getPrayerTitle(session),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              currentPrayerText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 17,
                height: 1.6,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControlsSection(RosarySession session) {
    final prayerTitle = _getPrayerTitle(session);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _audioDuration.inMilliseconds > 0
                  ? (_audioPosition.inMilliseconds /
                          _audioDuration.inMilliseconds)
                      .clamp(0.0, 1.0)
                  : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getMysteryColor(session.mysteryType),
                      _getMysteryColor(session.mysteryType).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: _getMysteryColor(session.mysteryType)
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_audioPosition),
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(_audioDuration),
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactControlButton(
                icon: _autoPlayEnabled
                    ? Icons.autorenew
                    : Icons.autorenew_outlined,
                onTap: () {
                  setState(() {
                    _autoPlayEnabled = !_autoPlayEnabled;
                  });
                },
                size: 25,
                isActive: _autoPlayEnabled,
              ),
              _buildNavigationButton(
                icon: Icons.skip_previous,
                onTap: _previousPrayer,
                isSecondary: true,
              ),
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getMysteryColor(session.mysteryType),
                      _getMysteryColor(session.mysteryType).withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => _playPrayerAudio(prayerTitle),
                    child: Icon(
                      _audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              _buildNavigationButton(
                icon: Icons.skip_next,
                onTap: _nextPrayer,
                isSecondary: false,
              ),
              _buildCompactControlButton(
                icon: Icons.volume_up,
                onTap: _showVolumeSlider,
                size: 25,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
    bool isActive = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: onTap,
      child: Icon(
        icon,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        size: size,
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isSecondary,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Icon(
        icon,
        color: isSecondary
            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
            : Colors.white,
        size: 40,
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

    HapticFeedback.lightImpact();

    if (completed && mounted) {
      _showCompletionDialog();
    } else if (mounted) {
      if (_rosaryService.currentSession != null) {
        final prayerTitle = _getPrayerTitle(_rosaryService.currentSession!);
        await _forcePlayPrayerAudio(prayerTitle);
      }
    }
  }

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
    return Theme.of(context).colorScheme.primary;
  }

  String _getCurrentMysteryDescription(RosarySession session) {
    final currentStep = _getCurrentStep(session);
    if (currentStep?.currentMystery != null) {
      return currentStep!.currentMystery!.description;
    }
    return '';
  }

  String _getCurrentMysteryTitle(RosarySession session) {
    final currentStep = _getCurrentStep(session);
    if (currentStep?.currentMystery != null) {
      return currentStep!.currentMystery!.title;
    }
    return _getMysteryDisplayName(session.mysteryType);
  }

  int _countAveMariasInCurrentMystery(RosarySession session) {
    final currentStep = _getCurrentStep(session);
    if (currentStep == null || !currentStep.isInMystery) {
      return 0;
    }

    int aveMariaCount = 0;
    final currentMysteryIndex = currentStep.mysteryIndex;

    for (int i = 0; i < session.completedPrayers; i++) {
      final step = session.prayerSteps[i];
      if (step.mysteryIndex == currentMysteryIndex &&
          step.type == PrayerTypeExpanded.aveMaria) {
        aveMariaCount++;
      }
    }

    if (session.completedPrayers < session.prayerSteps.length) {
      final currentPrayerStep = session.prayerSteps[session.completedPrayers];
      if (currentPrayerStep.mysteryIndex == currentMysteryIndex &&
          currentPrayerStep.type == PrayerTypeExpanded.aveMaria) {
        aveMariaCount++;
      }
    }

    return aveMariaCount;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _playPrayerAudio(String prayerTitle) async {
    try {
      if (_audioService.isPlaying) {
        await _audioService.pause();
        setState(() {});
        return;
      }

      if (_audioService.currentAudio != null && !_audioService.isPlaying) {
        await _audioService.resume();
      } else {
        await _forcePlayPrayerAudio(prayerTitle);
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reproduzir áudio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _forcePlayPrayerAudio(String prayerTitle) async {
    try {
      await _audioService.stop();

      _audioService.setCurrentPrayerByName(prayerTitle);

      _playStartTime = DateTime.now();
      _audioDuration = _getPrayerDuration(prayerTitle);
      _audioPosition = Duration.zero;

      switch (prayerTitle.toLowerCase()) {
        case 'sinal da cruz':
          await _audioService.playSinalDaCruz();
          break;
        case 'creio':
          await _audioService.playCreio();
          break;
        case 'ave maria':
          await _audioService.playAveMaria();
          break;
        case 'pai nosso':
          await _audioService.playPaiNosso();
          break;
        case 'glória':
          await _audioService.playGloriaAoPai();
          break;
        default:
          return;
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reproduzir áudio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _previousPrayer() {
    final success = _rosaryService.previousPrayer();

    if (success && mounted) {
      if (_rosaryService.currentSession != null) {
        final prayerTitle = _getPrayerTitle(_rosaryService.currentSession!);
        _forcePlayPrayerAudio(prayerTitle);
      }

      HapticFeedback.lightImpact();
    }
  }

  void _showVolumeSlider() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.volume_up,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Volume',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volume_down,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    Expanded(
                      child: Slider(
                        value: _audioService.volume,
                        onChanged: (value) async {
                          await _audioService.setVolume(value);
                          setDialogState(() {});
                          setState(() {});
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                    Icon(
                      Icons.volume_up,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_audioService.volume * 100).round()}%',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
