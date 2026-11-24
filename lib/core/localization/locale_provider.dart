import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/widgets/app_colors.dart';
import 'app_strings.dart';

class LocaleNotifier extends Notifier<Locale> {
  static const String _keyLocale = 'app_language_code';

  /// Loaded synchronously before `runApp` so the first frame already uses the
  /// saved language (no flash / no half-translated first page).
  static Locale initialLocale = const Locale('ar');

  static Future<void> loadInitialLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_keyLocale);
      if (code == 'ar' || code == 'fr' || code == 'en') {
        initialLocale = Locale(code!);
      }
    } catch (_) {
      initialLocale = const Locale('ar');
    }
  }

  @override
  Locale build() => initialLocale;

  Future<void> setLanguageCode(String code) async {
    if (state.languageCode == code) return;
    state = Locale(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocale, code);
    } catch (_) {}
  }

  bool get isArabic => state.languageCode == 'ar';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LanguagePickerDialog extends ConsumerWidget {
  const LanguagePickerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const LanguagePickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

    final languages = [
      {'code': 'ar', 'name': 'العربية (Arabic)', 'flag': '🇩🇿', 'desc': 'اللغة الافتراضية مع دعم RTL'},
      {'code': 'fr', 'name': 'Français (French)', 'flag': '🇫🇷', 'desc': 'Langue française'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'desc': 'Default international language'},
    ];

    return Dialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.language, color: colors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.language,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      Text(
                        s.t('Change Application Language'),
                        style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.mutedText, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final isSel = currentLocale.languageCode == lang['code'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    ref.read(localeProvider.notifier).setLanguageCode(lang['code']!);
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(context).pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(s.tf('Language changed to {language}', {
                          'language': lang['name']!,
                        })),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel
                          ? colors.primary.withValues(alpha: 0.16)
                          : colors.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel ? colors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                ),
                              ),
                              Text(
                                lang['desc']!,
                                style: GoogleFonts.poppins(fontSize: 10, color: colors.mutedText),
                              ),
                            ],
                          ),
                        ),
                        if (isSel)
                          Icon(Icons.check_circle, color: colors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
