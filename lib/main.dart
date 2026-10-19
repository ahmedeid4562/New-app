import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/routes/routes_app.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/locale_controller.dart';

import 'features/data/models/news_model.dart';
import 'features/data/services/notification_service.dart';

import 'features/view/screens/details_screen.dart';
import 'features/view/screens/login_screen.dart';
import 'features/view/screens/main_screen.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await Hive.initFlutter();
  await Hive.openBox('cached_news');
  await Hive.openBox('new_articles');
  final themeController = ThemeController();
 await themeController.loadTheme();

  final localeController = LocaleController();
 await localeController.loadLocale();
  await NotificationService.instance.initialize();
  runApp(
    NewsApp(
      themeController: themeController,
      localeController: localeController,
    ),
  );
}
class NewsApp extends StatelessWidget {
  final ThemeController themeController;
  final LocaleController localeController;

  const NewsApp({
    super.key,
    required this.themeController,
    required this.localeController,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        themeController,
        localeController,
      ]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'News App',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          locale: localeController.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AuthGate(
            themeController: themeController,
            localeController: localeController,
          ),
          onGenerateRoute: (settings) {
            if (settings.name == RoutesApp.details) {
              final arguments = settings.arguments;

              if (arguments is NewsModel) {
                return MaterialPageRoute(
                  builder: (_) => DetailsScreen(
                    news: arguments,
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Error'),
                  ),
                  body: const Center(
                    child: Text('Invalid news information'),
                  ),
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
class AuthGate extends StatelessWidget {
  final ThemeController themeController;
  final LocaleController localeController;

  const AuthGate({
    super.key,
    required this.themeController,
    required this.localeController,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint(
          'AuthGate state: ${snapshot.connectionState}, '
          'hasData: ${snapshot.hasData}, '
          'hasError: ${snapshot.hasError}',
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          debugPrint('AuthGate error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'An authentication error occurred.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          debugPrint('Authenticated user: ${user.uid}');
          return MainScreen(
            key: ValueKey(user.uid),
            themeController: themeController,
            localeController: localeController,
          );
        }
        debugPrint(
          'No authenticated user. Showing LoginScreen.',  );
          return const LoginScreen();
      },
    );
  }
}
