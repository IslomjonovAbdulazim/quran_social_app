import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';

// Import your app files
import 'core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'services/audio_service.dart';
import 'services/donwload_service.dart';

// Controllers and Services
import 'controllers/app_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/audio_controller.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app services and storage
  await initializeApp();

  // Run the app
  runApp(QuranSocialApp());
}

/// Initialize all app services, storage, and dependencies
Future<void> initializeApp() async {
  try {
    // Initialize GetX storage
    await GetStorage.init();

    // Initialize Hive for local storage
    await _initializeHive();

    // Initialize shared preferences
    await SharedPreferences.getInstance();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configure system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize audio service for background playback
    await _initializeAudioService();

    // Initialize download service
    await _initializeDownloadService();

    // Initialize GetX controllers and services
    _initializeControllers();

    print('✅ App initialization completed successfully');
  } catch (e, stackTrace) {
    print('❌ App initialization failed: $e');
    print('Stack trace: $stackTrace');
    // You might want to show an error dialog or handle this gracefully
  }
}

/// Initialize Hive database
Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();

    // Register adapters if you have custom models
    // Example: Hive.registerAdapter(UserAdapter());
    // Example: Hive.registerAdapter(BookmarkAdapter());

    // Open boxes for different data types
    await Hive.openBox('settings');
    await Hive.openBox('bookmarks');
    await Hive.openBox('favorites');
    await Hive.openBox('reading_progress');
    await Hive.openBox('user_data');

    print('✅ Hive database initialized');
  } catch (e) {
    print('❌ Hive initialization failed: $e');
    rethrow;
  }
}

/// Initialize audio service for background playback
Future<void> _initializeAudioService() async {
  try {
    // Initialize audio service with custom handler
    // Note: You'll need to create QuranAudioHandler
    // await AudioService.init(
    //   builder: () => QuranAudioHandler(),
    //   config: const AudioServiceConfig(
    //     androidNotificationChannelId: 'com.quran.social.audio',
    //     androidNotificationChannelName: 'Quran Audio',
    //     androidNotificationOngoing: true,
    //     androidShowNotificationBadge: true,
    //   ),
    // );

    print('✅ Audio service initialized');
  } catch (e) {
    print('❌ Audio service initialization failed: $e');
    // Don't rethrow - audio service failure shouldn't prevent app startup
  }
}

/// Initialize download service
Future<void> _initializeDownloadService() async {
  try {
    final downloadService = QuranAudioDownloadService();
    await downloadService.initialize();

    // Register as GetX service for dependency injection
    Get.put(downloadService, permanent: true);

    print('✅ Download service initialized');
  } catch (e) {
    print('❌ Download service initialization failed: $e');
    // Don't rethrow - download service failure shouldn't prevent app startup
  }
}

/// Initialize GetX controllers and services
void _initializeControllers() {
  try {
    // Core app controller
    Get.put(AppController(), permanent: true);

    // Theme controller
    Get.put(ThemeController(), permanent: true);

    // Audio controller
    Get.put(AudioController(), permanent: true);

    print('✅ Controllers initialized');
  } catch (e) {
    print('❌ Controllers initialization failed: $e');
    rethrow;
  }
}

class QuranSocialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Design size based on your UI design (adjust as needed)
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Quran Social App',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: Get.find<ThemeController>().themeMode,

          // Localization support
          locale: const Locale('ar', 'SA'), // Default to Arabic
          fallbackLocale: const Locale('en', 'US'),

          // Navigation configuration
          initialRoute: AppRoutes.SPLASH,
          getPages: AppPages.routes,

          // Default transitions
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),

          // Error handling
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const NotFoundPage(),
          ),

          // App lifecycle
          builder: (context, widget) {
            return MediaQuery(
              // Ensure text scaling doesn't break the UI
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
              ),
              child: widget!,
            );
          },
        );
      },
    );
  }
}

/// Splash screen to show while app is loading
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _startAnimation();
    _navigateToHome();
  }

  void _startAnimation() {
    _animationController.forward();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      Get.offNamed(AppRoutes.HOME);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(60.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 60.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // App name
                    Text(
                      'القرآن الاجتماعي',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'UthmaniHafs',
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      'Quran Social App',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: 50.h),

                    // Loading indicator
                    SizedBox(
                      width: 30.w,
                      height: 30.w,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Simple not found page for unknown routes
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.HOME),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}