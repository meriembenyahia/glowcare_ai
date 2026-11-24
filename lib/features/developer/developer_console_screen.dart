import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/role/role_provider.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/widgets/app_bar_title.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import '../ai_advisor/ai_settings_dialog.dart';
import '../loyalty/loyalty_card_screen.dart';
import '../loyalty/loyalty_provider.dart';
import '../orders/orders_provider.dart';
import '../shop/product_provider.dart';

class DeveloperConsoleScreen extends ConsumerStatefulWidget {
  const DeveloperConsoleScreen({super.key});

  @override
  ConsumerState<DeveloperConsoleScreen> createState() => _DeveloperConsoleScreenState();
}

class _DeveloperConsoleScreenState extends ConsumerState<DeveloperConsoleScreen> {
  bool _isTestingApi = false;
  String? _apiPingResult;

  Future<void> _testSupabase() async {
    setState(() {
      _isTestingApi = true;
      _apiPingResult = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final products = await SupabaseService.getProducts();
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isTestingApi = false;
          _apiPingResult = products != null
              ? '✅ Connected! Latency: ${stopwatch.elapsedMilliseconds}ms (${products.length} remote items found)'
              : '⚠️ Supabase returned 0 items or offline fallback is active (${stopwatch.elapsedMilliseconds}ms)';
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isTestingApi = false;
          _apiPingResult = '❌ Error connecting: $e (${stopwatch.elapsedMilliseconds}ms)';
        });
      }
    }
  }

  void _exportJsonDump() {
    final s = AppStrings.of(context);
    final colors = AppThemeColors.of(context);
    final orders = ref.read(ordersProvider);
    final products = ref.read(productsProvider).value ?? [];

    final dump = {
      'system': 'GlowCare AI E-Commerce Platform',
      'exportDate': DateTime.now().toIso8601String(),
      'license': 'GLOWCARE-ENTERPRISE-PRO-2026',
      'totalProducts': products.length,
      'totalOrders': orders.length,
      'products': products.map((p) => p.toJson()).toList(),
      'orders': orders.map((o) => o.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(dump);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: AppBarTitle(
          text: s.t('JSON Database Dump'),
          style: GoogleFonts.poppins(fontSize: 16, color: colors.text),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.t('JSON copied to clipboard!'))),
              );
            },
            child: Text(s.t('Copy JSON')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.t('Close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = ref.watch(ordersProvider);
    final products = ref.watch(productsProvider).value ?? [];
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Row(
          children: [
            const AppLogo(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t('Developer Console'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    s.t('Technical Diagnostics & Architecture'),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(roleProvider.notifier).setRole(AppRole.customer);
            },
            icon: Icon(Icons.swap_horiz, size: 16, color: colors.primary),
            label: Text(
              s.t('Customer View'),
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SaaS Platform License Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: isDark ? 0.3 : 0.15),
                      colors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.t('Commercial Turnkey Solution'),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: colors.text),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s.t('LICENSE ACTIVE'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.t('Ready-to-Sell E-Commerce Mobile Platform (Flutter & Dart)\nTenant: GlowCare Cosmetics SARL · License: GLOWCARE-ENTERPRISE-PRO-2026'),
                      style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Cloud Backend & Supabase Status
              Text(
                s.t('Cloud Backend & REST API Health'),
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                ListTile(
                  leading: const Icon(Icons.cloud_done, color: Colors.green),
                  title: Text(s.t('Supabase Cloud Backend'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                  subtitle: Text(
                    'URL: https://ppphfquwtjyacbeewjyc.supabase.co\n${s.t('Status')}: ${SupabaseService.isInitialized ? s.t('Initialized & Online') : s.t('Local Standby Mode')}',
                    style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
                  ),
                  trailing: ElevatedButton(
                    onPressed: _isTestingApi ? null : _testSupabase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                      minimumSize: const Size(80, 36),
                    ),
                    child: _isTestingApi
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(s.t('Ping API'), style: const TextStyle(fontSize: 11)),
                  ),
                ),
                if (_apiPingResult != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      _apiPingResult!,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text),
                    ),
                  ),
              ]),
              const SizedBox(height: 20),

              // 3. Database Tables Diagnostic
              Text(
                s.t('Database Tables & Record Counts'),
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _tableKpi(colors, 'products', '${products.length}', s.t('Active Catalog Items'), Icons.inventory),
                  const SizedBox(width: 10),
                  _tableKpi(colors, 'orders', '${orders.length}', s.t('Client Orders Stored'), Icons.receipt_long),
                  const SizedBox(width: 10),
                  _tableKpi(colors, 'wilayas', '58', s.t('Algeria Wilayas Matrix'), Icons.map),
                ],
              ),
              const SizedBox(height: 20),

              // 4. AI Engine Diagnostics
              Text(
                s.t('AI Subsystems Diagnostics'),
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                _aiModuleTile(colors, s.t('AI Skin Consultation Advisor'), s.t('Heuristic 3-factor diagnostic model (Skin type, concerns, climate factors)'), true),
                const Divider(height: 1),
                _aiModuleTile(colors, s.t('Beauty Lab AI Formula Analyzer'), s.t('Cosmetic chemical rule engine, clash detection & 0-100 safety score matrix'), true),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.purple),
                  title: Text(s.t('OpenAI ChatGPT Integration'), style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: FutureBuilder<AiConfig>(
                    future: AiService.instance.getConfig(),
                    builder: (context, snapshot) {
                      final config = snapshot.data;
                      final hasKey = config?.isConfigured ?? false;
                      return Text(
                        hasKey
                            ? '${s.t('Status')}: ${s.t(config!.provider.labelKey)} (${config.effectiveModel})'
                            : s.t('Status: Smart Local Engine (No API key set)'),
                        style: GoogleFonts.poppins(fontSize: 11, color: hasKey ? Colors.green : Colors.orange),
                      );
                    },
                  ),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      await AiSettingsDialog.show(context);
                      setState(() {});
                    },
                    child: Text(s.t('Configure'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.card_membership, color: Colors.amber),
                  title: Text(s.t('Carte de Fidélité (Loyalty System)'), style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: Consumer(
                    builder: (context, ref, _) {
                      final l = ref.watch(loyaltyProvider);
                      return Text(
                        s.tf('Current Points: {points} pts • Tier: {tier}', {
                          'points': '${l.totalPoints}',
                          'tier': '${l.tier.emoji} ${s.t(l.tier.label)}',
                        }),
                        style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
                      );
                    },
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoyaltyCardScreen()),
                    ),
                    child: Text(s.t('Open Card'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // 5. Developer Actions
              Text(
                s.t('Developer Data Actions'),
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                ListTile(
                  leading: const Icon(Icons.data_object, color: Colors.blue),
                  title: Text(s.t('Export JSON Database Dump'), style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: Text(s.t('Generate full structured JSON of products and orders'), style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText)),
                  trailing: OutlinedButton(
                    onPressed: _exportJsonDump,
                    child: Text(s.t('Export'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
                  title: Text(s.t('Seed Demo Products Catalog'), style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: Text(s.t('Populate catalog with 16 high-grade beauty products'), style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText)),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      await ref.read(productsProvider.notifier).resetToDefaults();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.t('Demo products catalog populated successfully!'))),
                      );
                    },
                    child: Text(s.t('Seed'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // 6. Technology Specifications
              Text(
                s.t('Tech Stack & Architecture'),
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                _specRow(colors, s.t('Framework'), 'Flutter 3.x (Cross-Platform Android/iOS/Web)'),
                _specRow(colors, s.t('Language'), 'Dart 3.x with Null Safety'),
                _specRow(colors, s.t('State Management'), 'Riverpod 3.x (AsyncNotifier + Notifier)'),
                _specRow(colors, s.t('Local Caching'), 'SharedPreferences (Offline-First Architecture)'),
                _specRow(colors, s.t('Cloud & BaaS'), 'Supabase (PostgreSQL with Row Level Security)'),
                _specRow(colors, s.t('Architecture'), 'Feature-First Clean Architecture'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(AppThemeColors colors, List<Widget> children) {
    return Material(
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _tableKpi(AppThemeColors colors, String tableName, String count, String desc, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tableName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(count, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: colors.primary)),
            Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 9, color: colors.mutedText)),
          ],
        ),
      ),
    );
  }

  Widget _aiModuleTile(AppThemeColors colors, String title, String desc, bool isReady) {
    final s = AppStrings.of(context);
    return ListTile(
      leading: const Icon(Icons.auto_awesome, color: Colors.purple),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
      subtitle: Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(s.t('READY'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green)),
      ),
    );
  }

  Widget _specRow(AppThemeColors colors, String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.mutedText)),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 12, color: colors.text),
            ),
          ),
        ],
      ),
    );
  }
}
