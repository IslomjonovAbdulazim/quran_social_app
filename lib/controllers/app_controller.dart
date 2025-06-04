import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class AppController extends GetxController {
  static AppController get instance => Get.find<AppController>();

  // Reactive variables
  final RxBool _isLoading = false.obs;
  final RxBool _isConnected = true.obs;
  final RxString _currentLanguage = 'ar'.obs;
  final RxBool _isFirstTime = true.obs;
  final RxString _appVersion = ''.obs;
  final RxString _deviceInfo = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isConnected => _isConnected.value;
  String get currentLanguage => _currentLanguage.value;
  bool get isFirstTime => _isFirstTime.value;
  String get appVersion => _appVersion.value;
  String get deviceInfo => _deviceInfo.value;

  // Services
  late SharedPreferences _prefs;
  late Connectivity _connectivity;
  late DeviceInfoPlugin _deviceInfoPlugin;
  late PackageInfo _packageInfo;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      setLoading(true);

      // Initialize services
      _prefs = await SharedPreferences.getInstance();
      _connectivity = Connectivity();
      _deviceInfoPlugin = DeviceInfoPlugin();
      _packageInfo = await PackageInfo.fromPlatform();

      // Load app state
      await _loadAppState();

      // Setup connectivity listener
      _setupConnectivityListener();

      // Get device info
      await _getDeviceInfo();

      // Get app version
      _getAppVersion();

      setLoading(false);
    } catch (e) {
      print('Error initializing AppController: $e');
      setLoading(false);
    }
  }

  /// Load app state from storage
  Future<void> _loadAppState() async {
    try {
      // Check if it's first time opening the app
      _isFirstTime.value = _prefs.getBool('first_time') ?? true;

      // Load saved language
      _currentLanguage.value = _prefs.getString('language') ?? 'ar';

      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _isConnected.value = result != ConnectivityResult.none;

    } catch (e) {
      print('Error loading app state: $e');
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool connected = results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (_isConnected.value != connected) {
        _isConnected.value = connected;

        // Show snackbar for connectivity changes
        if (connected) {
          Get.snackbar(
            'Connection Restored',
            'Internet connection is back online',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.primaryColor,
            colorText: Get.theme.colorScheme.onPrimary,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'No Internet',
            'Please check your internet connection',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
            duration: const Duration(seconds: 3),
          );
        }
      }
    });
  }

  /// Get device information
  Future<void> _getDeviceInfo() async {
    try {
      String deviceData = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceData = '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceData = '${iosInfo.name} ${iosInfo.model} (iOS ${iosInfo.systemVersion})';
      }

      _deviceInfo.value = deviceData;
    } catch (e) {
      print('Error getting device info: $e');
    }
  }

  /// Get app version information
  void _getAppVersion() {
    _appVersion.value = '${_packageInfo.version} (${_packageInfo.buildNumber})';
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    try {
      _currentLanguage.value = languageCode;
      await _prefs.setString('language', languageCode);

      // Update GetX locale
      Locale locale = Locale(languageCode);
      Get.updateLocale(locale);

      Get.snackbar(
        'Language Changed',
        'App language has been updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  /// Mark first time as completed
  Future<void> completeFirstTime() async {
    try {
      _isFirstTime.value = false;
      await _prefs.setBool('first_time', false);
    } catch (e) {
      print('Error completing first time: $e');
    }
  }

  /// Check for app updates (placeholder)
  Future<bool> checkForUpdates() async {
    try {
      // Implement your update check logic here
      // This could involve checking a remote server for version info

      // For now, return false (no updates available)
      return false;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  /// Clear app data (for settings/logout)
  Future<void> clearAppData() async {
    try {
      await _prefs.clear();

      // Reset to defaults
      _isFirstTime.value = true;
      _currentLanguage.value = 'ar';

      Get.snackbar(
        'Data Cleared',
        'App data has been cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error clearing app data: $e');
    }
  }

  /// Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      // This is a simplified version - you might want to use a more sophisticated approach
      final String? appDir = _prefs.getString('app_directory');

      return {
        'used_space': '0 MB', // Calculate actual used space
        'available_space': '1000 MB', // Calculate actual available space
        'total_downloads': 0, // Count actual downloads
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {
        'used_space': 'Unknown',
        'available_space': 'Unknown',
        'total_downloads': 0,
      };
    }
  }

  /// Show loading dialog
  void showLoadingDialog({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  message ?? 'Loading...',
                  style: Get.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show error dialog
  void showErrorDialog(String title, String message, {VoidCallback? onOk}) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onOk?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool> showConfirmationDialog(
      String title,
      String message, {
        String confirmText = 'Yes',
        String cancelText = 'No',
      }) async {
    bool result = false;

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              result = false;
              Get.back();
            },
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              result = true;
              Get.back();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result;
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}