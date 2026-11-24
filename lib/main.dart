import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/locale_provider.dart';
import 'core/services/ai_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/widgets/app_theme.dart';
import 'features/onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await AiService.instance.init();
  await LocaleNotifier.loadInitialLocale();

  runApp(const ProviderScope(child: GlowCareApp()));
}

class GlowCareApp extends ConsumerWidget {
  const GlowCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'GlowCare AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('fr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
