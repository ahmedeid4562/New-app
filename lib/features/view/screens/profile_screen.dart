import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  final ThemeController themeController;
  final LocaleController localeController;

  const ProfileScreen({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final localizations = AppLocalizations.of(context)!;

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            localizations.pleaseLoginToViewProfile,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.myProfile,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                localizations.failedToLoadProfile,
                textAlign: TextAlign.center,
              ),
            );
          }

          final Map<String, dynamic>? data =
              snapshot.data?.data();

          final String name =
              data?['name']?.toString() ?? localizations.user;

          final String email =
              data?['email']?.toString() ?? user.email ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 25),

                CircleAvatar(
                  radius: 55,
                  backgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person,
                    size: 65,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 35),

                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    localizations.accountInformation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context: context,
                        icon: Icons.person_outline,
                        title: localizations.fullName,
                        value: name,
                      ),

                      const Divider(height: 30),

                      _buildInfoRow(
                        context: context,
                        icon: Icons.email_outlined,
                        title: localizations.emailAddress,
                        value: email,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Dark Mode
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.dark_mode,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.darkMode,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              themeController.isDarkMode
                                  ? localizations.darkThemeEnabled
                                  : localizations.lightThemeEnabled,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Switch(
                        value: themeController.isDarkMode,
                        onChanged: (value) {
                          themeController.toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Language Settings
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.language,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.language,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              localizations.chooseAppLanguage,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      DropdownButton<String>(
                        value: localeController.locale.languageCode,
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(localizations.english),
                          ),
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text(localizations.arabic),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            localeController.changeLocale(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 26,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}