import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioController extends GetxController {
  static AudioController get instance => Get.find<AudioController>();

  // Audio player instance
  late AudioPlayer _audioPlayer;
  late AudioSession _audioSession;

  // Reactive variables
  final RxBool _isPlaying = false.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isPaused = false.obs;
  final RxDouble _currentPosition = 0.0.obs;
  final RxDouble _totalDuration = 0.0.obs;
  final RxDouble _playbackSpeed = 1.0.obs;
  final RxDouble _volume = 1.0.obs;
  final RxString _currentReciterId = ''.obs;
  final RxInt _currentSurahNumber = 0.obs;
  final RxString _currentSurahName = ''.obs;
  final RxBool _isRepeatMode = false.obs;
  final RxBool _isShuffleMode = false.obs;
  final RxBool _isAutoNext = true.obs;

  // Getters
  bool get isPlaying => _isPlaying.value;
  bool get isLoading => _isLoading.value;
  bool get isPaused => _isPaused.value;
  double get currentPosition => _currentPosition.value;
  double get totalDuration => _totalDuration.value;
  double get playbackSpeed => _playbackSpeed.value;
  double get volume => _volume.value;
  String get currentReciterId => _currentReciterId.value;
  int get currentSurahNumber => _currentSurahNumber.value;
  String get currentSurahName => _currentSurahName.value;
  bool get isRepeatMode => _isRepeatMode.value;
  bool get isShuffleMode => _isShuffleMode.value;
  bool get isAutoNext => _isAutoNext.value;

  // Stream subscriptions
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  // Available playback speeds
  final List<double> availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Surah names (simplified list - you should use your complete data)
  final Map<int, String> surahNames = {
    1: 'الفاتحة',
    2: 'البقرة',
    3: 'آل عمران',
    // Add all 114 surahs
  };

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initializeAudio();
  }

  /// Initialize audio player and session
  Future<void> _initializeAudio() async {
    try {
      // Initialize audio session
      _audioSession = await AudioSession.instance;
      await _audioSession.configure(const AudioSessionConfiguration.music());

      // Initialize audio player
      _audioPlayer = AudioPlayer();

      // Load saved settings
      await _loadAudioSettings();

      // Setup audio listeners
      _setupAudioListeners();

      print('✅ Audio controller initialized');
    } catch (e) {
      print('❌ Error initializing audio: $e');
    }
  }

  /// Load audio settings from storage
  Future<void> _loadAudioSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load volume
      _volume.value = _prefs.getDouble('audio_volume') ?? 1.0;
      await _audioPlayer.setVolume(_volume.value);

      // Load playback speed
      _playbackSpeed.value = _prefs.getDouble('playback_speed') ?? 1.0;
      await _audioPlayer.setSpeed(_playbackSpeed.value);

      // Load repeat mode
      _isRepeatMode.value = _prefs.getBool('repeat_mode') ?? false;

      // Load auto next
      _isAutoNext.value = _prefs.getBool('auto_next') ?? true;

      // Load last played surah info
      _currentReciterId.value = _prefs.getString('last_reciter_id') ?? '';
      _currentSurahNumber.value = _prefs.getInt('last_surah_number') ?? 0;
      _currentSurahName.value = _prefs.getString('last_surah_name') ?? '';

    } catch (e) {
      print('Error loading audio settings: $e');
    }
  }

  /// Setup audio event listeners
  void _setupAudioListeners() {
    // Position stream
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _currentPosition.value = position.inMilliseconds.toDouble();
    });

    // Duration stream
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration.value = duration.inMilliseconds.toDouble();
      }
    });

    // Player state stream
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying.value = state.playing;
      _isLoading.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;

      // Handle playback completion
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }
    });
  }

  /// Handle playback completion
  void _handlePlaybackCompleted() async {
    if (_isRepeatMode.value) {
      // Repeat current surah
      await seekTo(0);
      await play();
    } else if (_isAutoNext.value) {
      // Play next surah
      await playNextSurah();
    } else {
      // Stop playback
      _isPlaying.value = false;
      _isPaused.value = false;
    }
  }

  /// Play audio from URL or local file
  Future<void> playFromSource(String source, {
    String? reciterId,
    int? surahNumber,
    String? surahName,
  }) async {
    try {
      _isLoading.value = true;

      // Update current playing info
      if (reciterId != null) _currentReciterId.value = reciterId;
      if (surahNumber != null) {
        _currentSurahNumber.value = surahNumber;
        _currentSurahName.value = surahName ?? surahNames[surahNumber] ?? '';
      }

      // Set audio source
      await _audioPlayer.setUrl(source);

      // Save current playing info
      await _saveCurrentPlayingInfo();

      // Start playing
      await play();

    } catch (e) {
      _isLoading.value = false;
      _showError('Failed to load audio: $e');
    }
  }

  /// Play/resume audio
  Future<void> play() async {
    try {
      await _audioPlayer.play();
      _isPaused.value = false;
    } catch (e) {
      _showError('Failed to play audio: $e');
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPaused.value = true;
    } catch (e) {
      _showError('Failed to pause audio: $e');
    }
  }

  /// Stop audio
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying.value = false;
      _isPaused.value = false;
      _currentPosition.value = 0.0;
    } catch (e) {
      _showError('Failed to stop audio: $e');
    }
  }

  /// Seek to position (in milliseconds)
  Future<void> seekTo(double positionMs) async {
    try {
      final duration = Duration(milliseconds: positionMs.toInt());
      await _audioPlayer.seek(duration);
    } catch (e) {
      _showError('Failed to seek: $e');
    }
  }

  /// Seek forward by seconds
  Future<void> seekForward([int seconds = 10]) async {
    final newPosition = _currentPosition.value + (seconds * 1000);
    final maxPosition = _totalDuration.value;

    if (newPosition < maxPosition) {
      await seekTo(newPosition);
    } else {
      await seekTo(maxPosition);
    }
  }

  /// Seek backward by seconds
  Future<void> seekBackward([int seconds = 10]) async {
    final newPosition = _currentPosition.value - (seconds * 1000);

    if (newPosition > 0) {
      await seekTo(newPosition);
    } else {
      await seekTo(0);
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      volume = volume.clamp(0.0, 1.0);
      _volume.value = volume;
      await _audioPlayer.setVolume(volume);
      await _prefs.setDouble('audio_volume', volume);
    } catch (e) {
      _showError('Failed to set volume: $e');
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      if (availableSpeeds.contains(speed)) {
        _playbackSpeed.value = speed;
        await _audioPlayer.setSpeed(speed);
        await _prefs.setDouble('playback_speed', speed);

        Get.snackbar(
          'Playback Speed',
          'Speed set to ${speed}x',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      _showError('Failed to set playback speed: $e');
    }
  }

  /// Toggle repeat mode
  Future<void> toggleRepeatMode() async {
    try {
      _isRepeatMode.value = !_isRepeatMode.value;
      await _prefs.setBool('repeat_mode', _isRepeatMode.value);

      Get.snackbar(
        'Repeat Mode',
        _isRepeatMode.value ? 'Enabled' : 'Disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      _showError('Failed to toggle repeat mode: $e');
    }
  }

  /// Toggle auto next
  Future<void> toggleAutoNext() async {
    try {
      _isAutoNext.value = !_isAutoNext.value;
      await _prefs.setBool('auto_next', _isAutoNext.value);

      Get.snackbar(
        'Auto Next',
        _isAutoNext.value ? 'Enabled' : 'Disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      _showError('Failed to toggle auto next: $e');
    }
  }

  /// Play next surah
  Future<void> playNextSurah() async {
    if (_currentSurahNumber.value > 0 && _currentSurahNumber.value < 114) {
      final nextSurah = _currentSurahNumber.value + 1;
      // You'll need to implement the logic to get the audio source for the next surah
      // This is a placeholder
      await playFromSource(
        'next_surah_url', // Replace with actual URL/path logic
        reciterId: _currentReciterId.value,
        surahNumber: nextSurah,
        surahName: surahNames[nextSurah],
      );
    }
  }

  /// Play previous surah
  Future<void> playPreviousSurah() async {
    if (_currentSurahNumber.value > 1) {
      final prevSurah = _currentSurahNumber.value - 1;
      // You'll need to implement the logic to get the audio source for the previous surah
      // This is a placeholder
      await playFromSource(
        'prev_surah_url', // Replace with actual URL/path logic
        reciterId: _currentReciterId.value,
        surahNumber: prevSurah,
        surahName: surahNames[prevSurah],
      );
    }
  }

  /// Get current position as formatted string
  String get currentPositionString {
    return _formatDuration(Duration(milliseconds: _currentPosition.value.toInt()));
  }

  /// Get total duration as formatted string
  String get totalDurationString {
    return _formatDuration(Duration(milliseconds: _totalDuration.value.toInt()));
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (_totalDuration.value <= 0) return 0.0;
    return _currentPosition.value / _totalDuration.value;
  }

  /// Format duration to string (mm:ss)
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Save current playing info
  Future<void> _saveCurrentPlayingInfo() async {
    try {
      await _prefs.setString('last_reciter_id', _currentReciterId.value);
      await _prefs.setInt('last_surah_number', _currentSurahNumber.value);
      await _prefs.setString('last_surah_name', _currentSurahName.value);
    } catch (e) {
      print('Error saving playing info: $e');
    }
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Audio Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Clear audio session
  Future<void> clearSession() async {
    try {
      await stop();
      _currentReciterId.value = '';
      _currentSurahNumber.value = 0;
      _currentSurahName.value = '';
      _currentPosition.value = 0.0;
      _totalDuration.value = 0.0;
    } catch (e) {
      print('Error clearing audio session: $e');
    }
  }

  @override
  void onClose() {
    // Cancel subscriptions
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();

    // Dispose audio player
    _audioPlayer.dispose();

    super.onClose();
  }
}