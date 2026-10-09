import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'favorites_screen.dart';
import 'reading_history_screen.dart';
import 'profile_screen.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final ThemeController themeController;
  final LocaleController localeController;

  const MainScreen({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  bool isLoggingOut = false;

  late final List<Widget> screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const ReadingHistoryScreen(),
    ProfileScreen(
      themeController: widget.themeController,
      localeController: widget.localeController,
    ),
  ];

  Future<void> logout() async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
    } catch (error, stackTrace) {
      debugPrint('Logout error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      final localizations = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.logoutFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogLocalizations =
            AppLocalizations.of(dialogContext)!;

        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            size: 35,
          ),
          title: Text(dialogLocalizations.logout),
          content: Text(dialogLocalizations.confirmLogout),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(dialogLocalizations.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(dialogLocalizations.logout),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (shouldLogout == true) {
      await logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color selectedColor = isDark
        ? Colors.blueAccent
        : const Color(0xFF3F51B5);

    final Color unselectedColor =
        isDark ? Colors.white60 : Colors.grey;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: selectedColor.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: currentIndex == 0
                  ? selectedColor
                  : unselectedColor,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: selectedColor,
            ),
            label: localizations.home,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
              color: currentIndex == 1
                  ? selectedColor
                  : unselectedColor,
            ),
            selectedIcon: Icon(
              Icons.favorite,
              color: selectedColor,
            ),
            label: localizations.favorites,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history,
              color: currentIndex == 2
                  ? selectedColor
                  : unselectedColor,
            ),
            selectedIcon: Icon(
              Icons.history,
              color: selectedColor,
            ),
            label: localizations.history,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: currentIndex == 3
                  ? selectedColor
                  : unselectedColor,
            ),
            selectedIcon: Icon(
              Icons.person,
              color: selectedColor,
            ),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }
}