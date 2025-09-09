import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class SimpleAudioService {
  static final SimpleAudioService _instance = SimpleAudioService._internal();
  factory SimpleAudioService() => _instance;
  SimpleAudioService._internal() {
    _initializeVolume();
    _setupAudioPlayerListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAudio;
  double _volume = 1.0;
  void Function()? _onAudioComplete;

  final List<String> _availablePrayers = [
    'sinal-da-cruz',
    'creio',
    'pai-nosso',
    'ave-maria',
    'gloria-ao-pai',
  ];

  int _currentPrayerIndex = 0;

  bool get isPlaying => _isPlaying;
  String? get currentAudio => _currentAudio;
  double get volume => _volume;
  List<String> get availablePrayers => _availablePrayers;
  int get currentPrayerIndex => _currentPrayerIndex;

  /// Configura listeners do player de áudio
  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _currentAudio = null;
      developer.log('🎵 Áudio finalizado', name: 'SimpleAudioService');

      if (_onAudioComplete != null) {
        _onAudioComplete!();
      }
    });
  }

  /// Define o callback para quando o áudio termina
  void setOnAudioCompleteCallback(void Function()? callback) {
    _onAudioComplete = callback;
  }

  /// Inicializa o volume
  Future<void> _initializeVolume() async {
    try {
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      developer.log('Erro ao inicializar volume: $e',
          name: 'SimpleAudioService');
    }
  }

  Future<void> playAssetAudio(String assetPath) async {
    try {
      // Para qualquer áudio anterior
      await stop();

      _currentAudio = assetPath;
      developer.log('🎵 Tentando reproduzir: $assetPath',
          name: 'SimpleAudioService');

      // Teste para verificar se o asset existe
      try {
        final byteData = await rootBundle.load('assets/$assetPath');
        developer.log(
            '✅ Asset encontrado, tamanho: ${byteData.lengthInBytes} bytes',
            name: 'SimpleAudioService');
      } catch (e) {
        developer.log('❌ Erro ao carregar asset: $e',
            name: 'SimpleAudioService', level: 1000);
        _isPlaying = false;
        _currentAudio = null;
        return;
      }

      await _audioPlayer.play(AssetSource(assetPath));

      // Configura o volume
      await _audioPlayer.setVolume(_volume);

      _isPlaying = true;

      developer.log('✅ Áudio iniciado com sucesso com volume: $_volume',
          name: 'SimpleAudioService');
    } catch (e) {
      developer.log('❌ Erro ao reproduzir áudio: $e',
          name: 'SimpleAudioService', level: 1000);
      _isPlaying = false;
      _currentAudio = null;
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      developer.log('Erro ao pausar: $e',
          name: 'SimpleAudioService', level: 1000);
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      developer.log('Erro ao retomar: $e',
          name: 'SimpleAudioService', level: 1000);
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentAudio = null;
    } catch (e) {
      developer.log('Erro ao parar: $e',
          name: 'SimpleAudioService', level: 1000);
    }
  }

  /// Define o volume do áudio (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    try {
      // Garantir que o volume está no intervalo válido
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
      developer.log('🔊 Volume definido para: $_volume',
          name: 'SimpleAudioService');
    } catch (e) {
      developer.log('Erro ao definir volume: $e',
          name: 'SimpleAudioService', level: 1000);
    }
  }

  /// Navega para a oração anterior na lista
  Future<void> playPrevious() async {
    if (_currentPrayerIndex > 0) {
      _currentPrayerIndex--;
      await _playPrayerByIndex(_currentPrayerIndex);
    }
  }

  /// Navega para a próxima oração na lista
  Future<void> playNext() async {
    if (_currentPrayerIndex < _availablePrayers.length - 1) {
      _currentPrayerIndex++;
      await _playPrayerByIndex(_currentPrayerIndex);
    }
  }

  /// Reproduz uma oração pelo índice
  Future<void> _playPrayerByIndex(int index) async {
    if (index >= 0 && index < _availablePrayers.length) {
      final prayerName = _availablePrayers[index];
      await playAssetAudio('audio/rosary/$prayerName.wav');
    }
  }

  /// Define a oração atual pelo nome
  void setCurrentPrayerByName(String prayerName) {
    final index = _availablePrayers
        .indexOf(prayerName.toLowerCase().replaceAll(' ', '-'));
    if (index != -1) {
      _currentPrayerIndex = index;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  // Métodos específicos para orações do terço
  Future<void> playAveMaria() async {
    await playAssetAudio('audio/rosary/Charon/ave-maria.wav');
  }

  Future<void> playPaiNosso() async {
    await playAssetAudio('audio/rosary/Charon/pai-nosso.wav');
  }

  Future<void> playGloriaAoPai() async {
    await playAssetAudio('audio/rosary/Charon/gloria-ao-pai.wav');
  }

  Future<void> playSinalDaCruz() async {
    await playAssetAudio('audio/rosary/Charon/sinal-da-cruz.wav');
  }

  Future<void> playCreio() async {
    await playAssetAudio('audio/rosary/Charon/creio.wav');
  }

  Future<void> playFatima() async {
    await playAssetAudio('audio/rosary/Charon/fatima.wav');
  }

  Future<void> playSalveRainha() async {
    await playAssetAudio('audio/rosary/Charon/salve-rainha.wav');
  }

  Future<void> playMysteryIntroduction() async {
    // Por enquanto, pode ser um áudio genérico ou silêncio
    // Futuramente pode ter áudios específicos para cada mistério
    await playAssetAudio('audio/rosary/Charon/mystery-introduction.wav');
  }
}
