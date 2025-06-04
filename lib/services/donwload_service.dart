import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Models for download tracking
class ReciterInfo {
  final String id;
  final String name;
  final String baseUrl;
  final String audioFormat; // mp3, ogg, etc.

  ReciterInfo({
    required this.id,
    required this.name,
    required this.baseUrl,
    this.audioFormat = 'mp3',
  });
}

class SurahInfo {
  final int number;
  final String name;
  final String englishName;
  final int totalAyahs;

  SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    this.totalAyahs = 0,
  });
}

class DownloadProgress {
  final String reciterId;
  final int surahNumber;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final DownloadStatus status;
  final String? errorMessage;
  final Duration? estimatedTimeRemaining;
  final double downloadSpeed; // bytes per second

  DownloadProgress({
    required this.reciterId,
    required this.surahNumber,
    required this.progress,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    required this.status,
    this.errorMessage,
    this.estimatedTimeRemaining,
    this.downloadSpeed = 0.0,
  });
}

class ReciterStats {
  final String reciterId;
  final String reciterName;
  final int totalSurahs;
  final int downloadedSurahs;
  final int failedSurahs;
  final double totalSizeInMB;
  final List<int> downloadedSurahNumbers;
  final List<int> failedSurahNumbers;
  final DateTime? lastDownloadDate;
  final Duration totalDownloadTime;

  ReciterStats({
    required this.reciterId,
    required this.reciterName,
    this.totalSurahs = 114,
    this.downloadedSurahs = 0,
    this.failedSurahs = 0,
    this.totalSizeInMB = 0.0,
    this.downloadedSurahNumbers = const [],
    this.failedSurahNumbers = const [],
    this.lastDownloadDate,
    this.totalDownloadTime = Duration.zero,
  });

  double get completionPercentage => totalSurahs > 0 ? (downloadedSurahs / totalSurahs) * 100 : 0.0;
  bool get isComplete => downloadedSurahs == totalSurahs;

  ReciterStats copyWith({
    int? downloadedSurahs,
    int? failedSurahs,
    double? totalSizeInMB,
    List<int>? downloadedSurahNumbers,
    List<int>? failedSurahNumbers,
    DateTime? lastDownloadDate,
    Duration? totalDownloadTime,
  }) {
    return ReciterStats(
      reciterId: reciterId,
      reciterName: reciterName,
      totalSurahs: totalSurahs,
      downloadedSurahs: downloadedSurahs ?? this.downloadedSurahs,
      failedSurahs: failedSurahs ?? this.failedSurahs,
      totalSizeInMB: totalSizeInMB ?? this.totalSizeInMB,
      downloadedSurahNumbers: downloadedSurahNumbers ?? this.downloadedSurahNumbers,
      failedSurahNumbers: failedSurahNumbers ?? this.failedSurahNumbers,
      lastDownloadDate: lastDownloadDate ?? this.lastDownloadDate,
      totalDownloadTime: totalDownloadTime ?? this.totalDownloadTime,
    );
  }
}

enum DownloadStatus {
  waiting,
  downloading,
  completed,
  failed,
  paused,
  cancelled,
}

class QuranAudioDownloadService {
  static final QuranAudioDownloadService _instance = QuranAudioDownloadService._internal();
  factory QuranAudioDownloadService() => _instance;
  QuranAudioDownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, ReciterStats> _reciterStats = {};
  final StreamController<DownloadProgress> _progressController = StreamController<DownloadProgress>.broadcast();
  final StreamController<ReciterStats> _statsController = StreamController<ReciterStats>.broadcast();

  bool _isInitialized = false;
  String? _baseDirectory;

  // Stream getters
  Stream<DownloadProgress> get downloadProgressStream => _progressController.stream;
  Stream<ReciterStats> get statsUpdateStream => _statsController.stream;

  // Popular Quran reciters with their audio URLs
  final List<ReciterInfo> _popularReciters = [
    ReciterInfo(id: 'abdurrahman_as_sudais', name: 'Abdul Rahman As-Sudais', baseUrl: 'https://server8.mp3quran.net/sudais'),
    ReciterInfo(id: 'saad_al_ghamdi', name: 'Saad Al-Ghamdi', baseUrl: 'https://server7.mp3quran.net/s_gmd'),
    ReciterInfo(id: 'mishary_rashid', name: 'Mishary Rashid Al-Afasy', baseUrl: 'https://server8.mp3quran.net/afs'),
    ReciterInfo(id: 'maher_al_muaiqly', name: 'Maher Al-Muaiqly', baseUrl: 'https://server12.mp3quran.net/maher'),
    ReciterInfo(id: 'ahmed_al_ajmi', name: 'Ahmed Al-Ajmi', baseUrl: 'https://server10.mp3quran.net/ajm'),
    ReciterInfo(id: 'hani_ar_rifai', name: 'Hani Ar-Rifai', baseUrl: 'https://server6.mp3quran.net/rifai'),
  ];

  // Surah information
  final List<SurahInfo> _surahList = [
    SurahInfo(number: 1, name: 'الفاتحة', englishName: 'Al-Fatiha', totalAyahs: 7),
    SurahInfo(number: 2, name: 'البقرة', englishName: 'Al-Baqara', totalAyahs: 286),
    SurahInfo(number: 3, name: 'آل عمران', englishName: 'Al Imran', totalAyahs: 200),
    // Add all 114 surahs here - abbreviated for brevity
    // You'll need to add the complete list
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permissions
    await _requestPermissions();

    // Setup base directory
    await _setupDirectories();

    // Configure Dio
    _configureDio();

    // Load existing stats
    await _loadStats();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final permissions = [
        Permission.storage,
        Permission.manageExternalStorage,
      ];

      for (final permission in permissions) {
        final status = await permission.request();
        if (status != PermissionStatus.granted) {
          throw Exception('Storage permission is required for downloading audio files');
        }
      }
    }
  }

  Future<void> _setupDirectories() async {
    final Directory appDir;
    if (Platform.isAndroid) {
      appDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      appDir = await getApplicationDocumentsDirectory();
    }

    _baseDirectory = path.join(appDir.path, 'QuranAudio');

    // Create base directory if it doesn't exist
    final baseDir = Directory(_baseDirectory!);
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
  }

  void _configureDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(minutes: 10);
    _dio.options.headers = {
      'User-Agent': 'QuranSocialApp/1.0.0',
    };
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    for (final reciter in _popularReciters) {
      final statsJson = prefs.getString('reciter_stats_${reciter.id}');
      if (statsJson != null) {
        // Parse stored stats - implement JSON parsing
        _reciterStats[reciter.id] = ReciterStats(
          reciterId: reciter.id,
          reciterName: reciter.name,
        );
      } else {
        _reciterStats[reciter.id] = ReciterStats(
          reciterId: reciter.id,
          reciterName: reciter.name,
        );
      }
    }
  }

  Future<void> _saveStats(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = _reciterStats[reciterId];
    if (stats != null) {
      // Save stats as JSON - implement JSON serialization
      await prefs.setString('reciter_stats_$reciterId', 'JSON_DATA');
    }
  }

  // Check network connectivity
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get file size from URL
  Future<int> _getFileSize(String url) async {
    try {
      final response = await _dio.head(url);
      final contentLength = response.headers.value('content-length');
      return contentLength != null ? int.parse(contentLength) : 0;
    } catch (e) {
      return 0;
    }
  }

  // Generate audio URL for specific surah and reciter
  String _generateAudioUrl(ReciterInfo reciter, int surahNumber) {
    final paddedSurahNumber = surahNumber.toString().padLeft(3, '0');
    return '${reciter.baseUrl}/$paddedSurahNumber.${reciter.audioFormat}';
  }

  // Get local file path
  String _getLocalFilePath(String reciterId, int surahNumber) {
    final paddedSurahNumber = surahNumber.toString().padLeft(3, '0');
    return path.join(_baseDirectory!, reciterId, '$paddedSurahNumber.mp3');
  }

  // Check if file already exists
  Future<bool> isSurahDownloaded(String reciterId, int surahNumber) async {
    final filePath = _getLocalFilePath(reciterId, surahNumber);
    final file = File(filePath);
    return await file.exists();
  }

  // Download single surah
  Future<void> downloadSurah({
    required String reciterId,
    required int surahNumber,
    bool overrideExisting = false,
  }) async {
    if (!await _hasInternetConnection()) {
      throw Exception('No internet connection available');
    }

    final reciter = _popularReciters.firstWhere((r) => r.id == reciterId);
    final audioUrl = _generateAudioUrl(reciter, surahNumber);
    final localFilePath = _getLocalFilePath(reciterId, surahNumber);

    // Check if already exists
    if (!overrideExisting && await isSurahDownloaded(reciterId, surahNumber)) {
      _emitProgress(reciterId, surahNumber, 1.0, DownloadStatus.completed);
      return;
    }

    // Create directory if it doesn't exist
    final directory = Directory(path.dirname(localFilePath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final cancelToken = CancelToken();
    final downloadKey = '${reciterId}_$surahNumber';
    _cancelTokens[downloadKey] = cancelToken;

    try {
      _emitProgress(reciterId, surahNumber, 0.0, DownloadStatus.downloading);

      final stopwatch = Stopwatch()..start();
      int lastBytes = 0;
      DateTime lastTime = DateTime.now();

      await _dio.download(
        audioUrl,
        localFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            final now = DateTime.now();
            final timeDiff = now.difference(lastTime).inMilliseconds;

            double speed = 0.0;
            Duration? eta;

            if (timeDiff > 500) { // Update every 500ms
              final bytesDiff = received - lastBytes;
              speed = (bytesDiff * 1000) / timeDiff; // bytes per second

              if (speed > 0) {
                final remainingBytes = total - received;
                eta = Duration(seconds: (remainingBytes / speed).round());
              }

              lastBytes = received;
              lastTime = now;
            }

            _emitProgress(
              reciterId,
              surahNumber,
              progress,
              DownloadStatus.downloading,
              downloadedBytes: received,
              totalBytes: total,
              downloadSpeed: speed,
              estimatedTimeRemaining: eta,
            );
          }
        },
      );

      stopwatch.stop();

      // Update stats
      await _updateStats(reciterId, surahNumber, localFilePath, stopwatch.elapsed, true);

      _emitProgress(reciterId, surahNumber, 1.0, DownloadStatus.completed);

    } catch (e) {
      await _updateStats(reciterId, surahNumber, localFilePath, Duration.zero, false);

      String errorMessage = 'Download failed';
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            errorMessage = 'Connection timeout';
            break;
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Download timeout';
            break;
          case DioExceptionType.cancel:
            errorMessage = 'Download cancelled';
            break;
          default:
            errorMessage = 'Network error: ${e.message}';
        }
      }

      _emitProgress(
        reciterId,
        surahNumber,
        0.0,
        DownloadStatus.failed,
        errorMessage: errorMessage,
      );

      rethrow;
    } finally {
      _cancelTokens.remove(downloadKey);
    }
  }

  // Download multiple surahs for a reciter
  Future<void> downloadSurahs({
    required String reciterId,
    required List<int> surahNumbers,
    bool overrideExisting = false,
    int maxConcurrentDownloads = 3,
  }) async {
    final semaphore = Semaphore(maxConcurrentDownloads);
    final futures = surahNumbers.map((surahNumber) async {
      await semaphore.acquire();
      try {
        await downloadSurah(
          reciterId: reciterId,
          surahNumber: surahNumber,
          overrideExisting: overrideExisting,
        );
      } finally {
        semaphore.release();
      }
    });

    await Future.wait(futures);
  }

  // Download entire Quran for a reciter
  Future<void> downloadCompleteQuran({
    required String reciterId,
    bool overrideExisting = false,
    int maxConcurrentDownloads = 2,
  }) async {
    final allSurahs = List.generate(114, (index) => index + 1);
    await downloadSurahs(
      reciterId: reciterId,
      surahNumbers: allSurahs,
      overrideExisting: overrideExisting,
      maxConcurrentDownloads: maxConcurrentDownloads,
    );
  }

  // Cancel download
  void cancelDownload(String reciterId, int surahNumber) {
    final downloadKey = '${reciterId}_$surahNumber';
    final cancelToken = _cancelTokens[downloadKey];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('User cancelled download');
    }
  }

  // Cancel all downloads for a reciter
  void cancelReciterDownloads(String reciterId) {
    final keysToCancel = _cancelTokens.keys
        .where((key) => key.startsWith('${reciterId}_'))
        .toList();

    for (final key in keysToCancel) {
      final cancelToken = _cancelTokens[key];
      if (cancelToken != null && !cancelToken.isCancelled) {
        cancelToken.cancel('User cancelled reciter downloads');
      }
    }
  }

  // Delete downloaded surah
  Future<bool> deleteSurah(String reciterId, int surahNumber) async {
    try {
      final filePath = _getLocalFilePath(reciterId, surahNumber);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        await _updateStatsAfterDeletion(reciterId, surahNumber);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete all downloads for a reciter
  Future<void> deleteReciterDownloads(String reciterId) async {
    try {
      final reciterDir = Directory(path.join(_baseDirectory!, reciterId));
      if (await reciterDir.exists()) {
        await reciterDir.delete(recursive: true);
        await _resetReciterStats(reciterId);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateStats(String reciterId, int surahNumber, String filePath, Duration downloadTime, bool success) async {
    final currentStats = _reciterStats[reciterId]!;
    final file = File(filePath);

    if (success && await file.exists()) {
      final fileSize = await file.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      final updatedDownloadedSurahs = List<int>.from(currentStats.downloadedSurahNumbers);
      if (!updatedDownloadedSurahs.contains(surahNumber)) {
        updatedDownloadedSurahs.add(surahNumber);
      }

      final updatedFailedSurahs = List<int>.from(currentStats.failedSurahNumbers);
      updatedFailedSurahs.remove(surahNumber);

      final updatedStats = currentStats.copyWith(
        downloadedSurahs: updatedDownloadedSurahs.length,
        failedSurahs: updatedFailedSurahs.length,
        totalSizeInMB: currentStats.totalSizeInMB + fileSizeInMB,
        downloadedSurahNumbers: updatedDownloadedSurahs,
        failedSurahNumbers: updatedFailedSurahs,
        lastDownloadDate: DateTime.now(),
        totalDownloadTime: currentStats.totalDownloadTime + downloadTime,
      );

      _reciterStats[reciterId] = updatedStats;
    } else {
      final updatedFailedSurahs = List<int>.from(currentStats.failedSurahNumbers);
      if (!updatedFailedSurahs.contains(surahNumber)) {
        updatedFailedSurahs.add(surahNumber);
      }

      final updatedStats = currentStats.copyWith(
        failedSurahs: updatedFailedSurahs.length,
        failedSurahNumbers: updatedFailedSurahs,
      );

      _reciterStats[reciterId] = updatedStats;
    }

    await _saveStats(reciterId);
    _statsController.add(_reciterStats[reciterId]!);
  }

  Future<void> _updateStatsAfterDeletion(String reciterId, int surahNumber) async {
    final currentStats = _reciterStats[reciterId]!;

    final updatedDownloadedSurahs = List<int>.from(currentStats.downloadedSurahNumbers);
    updatedDownloadedSurahs.remove(surahNumber);

    // Recalculate total size
    double totalSize = 0.0;
    for (final surah in updatedDownloadedSurahs) {
      final filePath = _getLocalFilePath(reciterId, surah);
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        totalSize += fileSize / (1024 * 1024);
      }
    }

    final updatedStats = currentStats.copyWith(
      downloadedSurahs: updatedDownloadedSurahs.length,
      totalSizeInMB: totalSize,
      downloadedSurahNumbers: updatedDownloadedSurahs,
    );

    _reciterStats[reciterId] = updatedStats;
    await _saveStats(reciterId);
    _statsController.add(_reciterStats[reciterId]!);
  }

  Future<void> _resetReciterStats(String reciterId) async {
    final reciter = _popularReciters.firstWhere((r) => r.id == reciterId);
    _reciterStats[reciterId] = ReciterStats(
      reciterId: reciterId,
      reciterName: reciter.name,
    );

    await _saveStats(reciterId);
    _statsController.add(_reciterStats[reciterId]!);
  }

  void _emitProgress(
      String reciterId,
      int surahNumber,
      double progress,
      DownloadStatus status, {
        int downloadedBytes = 0,
        int totalBytes = 0,
        String? errorMessage,
        double downloadSpeed = 0.0,
        Duration? estimatedTimeRemaining,
      }) {
    final downloadProgress = DownloadProgress(
      reciterId: reciterId,
      surahNumber: surahNumber,
      progress: progress,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
      status: status,
      errorMessage: errorMessage,
      downloadSpeed: downloadSpeed,
      estimatedTimeRemaining: estimatedTimeRemaining,
    );

    _progressController.add(downloadProgress);
  }

  // Getters
  List<ReciterInfo> get availableReciters => _popularReciters;
  List<SurahInfo> get surahList => _surahList;
  ReciterStats? getReciterStats(String reciterId) => _reciterStats[reciterId];
  Map<String, ReciterStats> get allReciterStats => Map.unmodifiable(_reciterStats);

  // Calculate total storage used
  Future<double> getTotalStorageUsed() async {
    double totalSize = 0.0;
    for (final stats in _reciterStats.values) {
      totalSize += stats.totalSizeInMB;
    }
    return totalSize;
  }

  // Get available storage
  Future<double> getAvailableStorage() async {
    if (_baseDirectory != null) {
      final directory = Directory(_baseDirectory!);
      final stat = await directory.stat();
      // This is a simplified approach - you might need platform-specific code
      return 1000.0; // Return available space in MB
    }
    return 0.0;
  }

  void dispose() {
    // Cancel all active downloads
    for (final cancelToken in _cancelTokens.values) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Service disposed');
      }
    }
    _cancelTokens.clear();

    _progressController.close();
    _statsController.close();
  }
}

// Semaphore for controlling concurrent downloads
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}