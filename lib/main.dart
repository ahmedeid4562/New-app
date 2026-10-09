import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:news_app/features/data/models/news_model.dart';
import 'package:news_app/features/view/screens/details_screen.dart';
import 'package:news_app/features/view/screens/login_screen.dart';
import 'package:news_app/features/view/screens/main_screen.dart';

import 'core/routes/routes_app.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/locale_controller.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeController = ThemeController();
  await themeController.loadTheme();

  final localeController = LocaleController();
  await localeController.loadLocale();

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
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: localeController,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

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

              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final localizations = AppLocalizations.of(context)!;

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            localizations.somethingWentWrong,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    return MainScreen(
                      themeController: themeController,
                      localeController: localeController,
                    );
                  }

                  return const LoginScreen();
                },
              ),

              onGenerateRoute: (settings) {
                if (settings.name == RoutesApp.details) {
                  final argument = settings.arguments;

                  if (argument is! NewsModel) {
                    return MaterialPageRoute<void>(
                      builder: (context) {
                        return Scaffold(
                          appBar: AppBar(),
                          body: Builder(
                            builder: (context) {
                              final localizations =
                                  AppLocalizations.of(context)!;

                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    localizations.invalidArticleLink,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  return MaterialPageRoute<void>(
                    builder: (context) {
                      return DetailsScreen(
                        news: argument,
                      );
                    },
                  );
                }

                return null;
              },
            );
          },
        );
      },
    );
  }
}