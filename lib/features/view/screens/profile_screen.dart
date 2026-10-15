import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/routes_app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeController themeController;
  final LocaleController localeController;

  const ProfileScreen({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _profileImage;

  bool _isLoadingImage = true;
  bool _isPickingImage = false;
  bool _isLoggingOut = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  String get _imageKey => 'profile_image_${_user?.uid ?? ''}';

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  String get _chooseImageText =>
      _isArabic ? 'اختار صورة' : 'Choose photo';

  String get _changeImageText =>
      _isArabic ? 'تغيير الصورة' : 'Change photo';

  String get _logoutText =>
      _isArabic ? 'تسجيل الخروج' : 'Log out';

  String get _logoutConfirmationText => _isArabic
      ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
      : 'Are you sure you want to log out?';

  String get _cancelText => _isArabic ? 'إلغاء' : 'Cancel';

  String get _confirmText =>
      _isArabic ? 'تسجيل الخروج' : 'Log out';

  String get _logoutErrorText => _isArabic
      ? 'تعذر تسجيل الخروج، حاول مرة أخرى'
      : 'Failed to log out. Please try again';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Load the saved profile image.
  Future<void> _loadProfileImage() async {
    try {
      final user = _user;

      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final savedImage = prefs.getString(_imageKey);

      if (savedImage != null && savedImage.isNotEmpty) {
        final bytes = base64Decode(savedImage);

        if (mounted) {
          setState(() {
            _profileImage = bytes;
          });
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load profile image: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  // Pick and save a profile image.
  Future<void> _pickProfileImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      // The user cancelled the selection.
      if (pickedFile == null) {
        debugPrint('Image selection cancelled.');
        return;
      }

      final bytes = await pickedFile.readAsBytes();

      debugPrint('Image selected: ${pickedFile.name}');
      debugPrint('Image size: ${bytes.length} bytes');

      final user = _user;

      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      final prefs = await SharedPreferences.getInstance();

      final saved = await prefs.setString(
        'profile_image_${user.uid}',
        base64Encode(bytes),
      );

      if (!saved) {
        throw Exception(
          'Failed to save image in SharedPreferences.',
        );
      }

      if (!mounted) return;

      setState(() {
        _profileImage = bytes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'تم تحديث الصورة الشخصية بنجاح'
                : 'Profile photo updated successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('FAILED TO SELECT IMAGE: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_isArabic ? 'خطأ في الصورة' : 'Image error'}: $error',
          ),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  // Remove the saved profile image.
  Future<void> _removeProfileImage() async {
    try {
      final user = _user;

      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_${user.uid}');

      if (!mounted) return;

      setState(() {
        _profileImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'تم حذف الصورة الشخصية'
                : 'Profile photo removed',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      debugPrint('Failed to remove profile image: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'تعذر حذف الصورة'
                : 'Failed to remove profile photo',
          ),
        ),
      );
    }
  }

  // Show logout confirmation.
  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final localizations = AppLocalizations.of(context)!;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.red,
            size: 35,
          ),
          title: Text(localizations.logout),
          content: Text(_logoutConfirmationText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(_cancelText),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(_confirmText),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutesApp.loginScreen,
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to log out: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_logoutErrorText),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _user;
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

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

          final data = snapshot.data?.data();

          final String name =
              data?['name']?.toString() ?? localizations.user;

          final String email =
              data?['email']?.toString() ?? user.email ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 15),

                // Profile photo.
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor:
                            AppTheme.primaryColor.withValues(
                          alpha: 0.15,
                        ),
                        backgroundImage: _profileImage != null
                            ? MemoryImage(_profileImage!)
                            : null,
                        child: _isLoadingImage
                            ? const CircularProgressIndicator()
                            : _profileImage == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 65,
                                    color: AppTheme.primaryColor,
                                  )
                                : null,
                      ),
                    ),
                    Material(
                      color: AppTheme.primaryColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isPickingImage
                            ? null
                            : _pickProfileImage,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _isPickingImage
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed:
                      _isPickingImage ? null : _pickProfileImage,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: Text(
                    _profileImage == null
                        ? _chooseImageText
                        : _changeImageText,
                  ),
                ),

                if (_profileImage != null)
                  TextButton.icon(
                    onPressed: _removeProfileImage,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    label: Text(
                      _isArabic
                          ? 'حذف الصورة'
                          : 'Remove photo',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

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

                // Account information heading.
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
                    color: theme.cardColor,
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

                // Dark mode settings.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.dark_mode_rounded,
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
                              widget.themeController.isDarkMode
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
                        value:
                            widget.themeController.isDarkMode,
                        onChanged: (value) {
                          widget.themeController.toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Language settings.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.language_rounded,
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
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<String>(
                        value: widget
                            .localeController.locale.languageCode,
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
                            widget.localeController
                                .changeLocale(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Logout button.
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isLoggingOut ? null : _confirmLogout,
                    icon: _isLoggingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.logout_rounded,
                          ),
                    label: Text(
                      _isLoggingOut
                          ? (_isArabic
                              ? 'جارٍ تسجيل الخروج...'
                              : 'Logging out...')
                          : _logoutText,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
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
