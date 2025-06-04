import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'app_routes.dart';

// Import your page files (you'll need to create these)
// import '../pages/splash/splash_page.dart';
// import '../pages/onboarding/onboarding_page.dart';
// import '../pages/home/home_page.dart';
// import '../pages/quran/quran_page.dart';
// import '../pages/settings/settings_page.dart';
// ... import other pages

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    // Splash Screen
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashScreen(), // Already defined in main.dart
      transition: Transition.fadeIn,
    ),

    // Onboarding
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingPage(),
      transition: Transition.rightToLeft,
    ),

    // Home
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),

    // Authentication
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
      transition: Transition.rightToLeft,
    ),

    // Quran Features
    GetPage(
      name: AppRoutes.QURAN,
      page: () => const QuranPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.MUSHAF,
      page: () => const MushafPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.SURAH_LIST,
      page: () => const SurahListPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.SURAH_DETAIL,
      page: () => const SurahDetailPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.AYAH_DETAIL,
      page: () => const AyahDetailPage(),
      transition: Transition.rightToLeft,
    ),

    // Audio Features
    GetPage(
      name: AppRoutes.AUDIO_PLAYER,
      page: () => const AudioPlayerPage(),
      transition: Transition.downToUp,
    ),

    GetPage(
      name: AppRoutes.RECITER_LIST,
      page: () => const ReciterListPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.RECITER_DETAIL,
      page: () => const ReciterDetailPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.DOWNLOAD_MANAGER,
      page: () => const DownloadManagerPage(),
      transition: Transition.rightToLeft,
    ),

    // Social Features
    GetPage(
      name: AppRoutes.BOOKMARKS,
      page: () => const BookmarksPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.FAVORITES,
      page: () => const FavoritesPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.SHARING,
      page: () => const SharingPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.COMMUNITY,
      page: () => const CommunityPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.DISCUSSIONS,
      page: () => const DiscussionsPage(),
      transition: Transition.rightToLeft,
    ),

    // Search Features
    GetPage(
      name: AppRoutes.SEARCH,
      page: () => const SearchPage(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.SEARCH_RESULTS,
      page: () => const SearchResultsPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.ADVANCED_SEARCH,
      page: () => const AdvancedSearchPage(),
      transition: Transition.rightToLeft,
    ),

    // Settings
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.THEME_SETTINGS,
      page: () => const ThemeSettingsPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.AUDIO_SETTINGS,
      page: () => const AudioSettingsPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.LANGUAGE_SETTINGS,
      page: () => const LanguageSettingsPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.NOTIFICATION_SETTINGS,
      page: () => const NotificationSettingsPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.STORAGE_SETTINGS,
      page: () => const StorageSettingsPage(),
      transition: Transition.rightToLeft,
    ),

    // Profile
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfilePage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.READING_PROGRESS,
      page: () => const ReadingProgressPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.ACHIEVEMENTS,
      page: () => const AchievementsPage(),
      transition: Transition.rightToLeft,
    ),

    // Additional Features
    GetPage(
      name: AppRoutes.TAFSIR,
      page: () => const TafsirPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.TRANSLATION,
      page: () => const TranslationPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.QIBLA,
      page: () => const QiblaPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.PRAYER_TIMES,
      page: () => const PrayerTimesPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.HIJRI_CALENDAR,
      page: () => const HijriCalendarPage(),
      transition: Transition.rightToLeft,
    ),

    // Utility Pages
    GetPage(
      name: AppRoutes.ABOUT,
      page: () => const AboutPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.HELP,
      page: () => const HelpPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.CONTACT,
      page: () => const ContactPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.TERMS_OF_SERVICE,
      page: () => const TermsOfServicePage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

// Placeholder pages - you'll need to create these actual page files
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Onboarding Page - To be implemented'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Page - To be implemented'),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Page - To be implemented'),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Register Page - To be implemented'),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Forgot Password Page - To be implemented'),
      ),
    );
  }
}

class QuranPage extends StatelessWidget {
  const QuranPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Quran Page - To be implemented'),
      ),
    );
  }
}

class MushafPage extends StatelessWidget {
  const MushafPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mushaf Page - To be implemented'),
      ),
    );
  }
}

class SurahListPage extends StatelessWidget {
  const SurahListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Surah List Page - To be implemented'),
      ),
    );
  }
}

class SurahDetailPage extends StatelessWidget {
  const SurahDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Surah Detail Page - To be implemented'),
      ),
    );
  }
}

class AyahDetailPage extends StatelessWidget {
  const AyahDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Ayah Detail Page - To be implemented'),
      ),
    );
  }
}

class AudioPlayerPage extends StatelessWidget {
  const AudioPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Audio Player Page - To be implemented'),
      ),
    );
  }
}

class ReciterListPage extends StatelessWidget {
  const ReciterListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Reciter List Page - To be implemented'),
      ),
    );
  }
}

class ReciterDetailPage extends StatelessWidget {
  const ReciterDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Reciter Detail Page - To be implemented'),
      ),
    );
  }
}

class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Download Manager Page - To be implemented'),
      ),
    );
  }
}

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Bookmarks Page - To be implemented'),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Favorites Page - To be implemented'),
      ),
    );
  }
}

class SharingPage extends StatelessWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Sharing Page - To be implemented'),
      ),
    );
  }
}

class CommunityPage extends StatelessWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Community Page - To be implemented'),
      ),
    );
  }
}

class DiscussionsPage extends StatelessWidget {
  const DiscussionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Discussions Page - To be implemented'),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Search Page - To be implemented'),
      ),
    );
  }
}

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Search Results Page - To be implemented'),
      ),
    );
  }
}

class AdvancedSearchPage extends StatelessWidget {
  const AdvancedSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Advanced Search Page - To be implemented'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Page - To be implemented'),
      ),
    );
  }
}

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Theme Settings Page - To be implemented'),
      ),
    );
  }
}

class AudioSettingsPage extends StatelessWidget {
  const AudioSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Audio Settings Page - To be implemented'),
      ),
    );
  }
}

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Language Settings Page - To be implemented'),
      ),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Notification Settings Page - To be implemented'),
      ),
    );
  }
}

class StorageSettingsPage extends StatelessWidget {
  const StorageSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Storage Settings Page - To be implemented'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Page - To be implemented'),
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Edit Profile Page - To be implemented'),
      ),
    );
  }
}

class ReadingProgressPage extends StatelessWidget {
  const ReadingProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Reading Progress Page - To be implemented'),
      ),
    );
  }
}

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Achievements Page - To be implemented'),
      ),
    );
  }
}

class TafsirPage extends StatelessWidget {
  const TafsirPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Tafsir Page - To be implemented'),
      ),
    );
  }
}

class TranslationPage extends StatelessWidget {
  const TranslationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Translation Page - To be implemented'),
      ),
    );
  }
}

class QiblaPage extends StatelessWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Qibla Page - To be implemented'),
      ),
    );
  }
}

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Prayer Times Page - To be implemented'),
      ),
    );
  }
}

class HijriCalendarPage extends StatelessWidget {
  const HijriCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Hijri Calendar Page - To be implemented'),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('About Page - To be implemented'),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Help Page - To be implemented'),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Contact Page - To be implemented'),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Privacy Policy Page - To be implemented'),
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Terms of Service Page - To be implemented'),
      ),
    );
  }
}