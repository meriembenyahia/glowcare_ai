import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
import '../ingredients/ingredient_checker_screen.dart';
import '../shop/product.dart';
import '../shop/product_details_screen.dart';
import '../shop/product_provider.dart';
import 'ai_settings_dialog.dart';

class SkinDiagnosis {
  final int healthScore;
  final String conditionSummary;
  final String keyRecommendation;
  final List<String> morningRoutine;
  final List<String> nightRoutine;
  final List<String> targetActives;
  final List<String> avoidActives;
  final List<String> keywords;

  const SkinDiagnosis({
    required this.healthScore,
    required this.conditionSummary,
    required this.keyRecommendation,
    required this.morningRoutine,
    required this.nightRoutine,
    required this.targetActives,
    required this.avoidActives,
    required this.keywords,
  });
}

class AiSkinAnalysisScreen extends ConsumerStatefulWidget {
  const AiSkinAnalysisScreen({super.key});

  @override
  ConsumerState<AiSkinAnalysisScreen> createState() => _AiSkinAnalysisScreenState();
}

class _AiSkinAnalysisScreenState extends ConsumerState<AiSkinAnalysisScreen> {
  int _step = 0; // 0: Skin Type, 1: Concern, 2: Environment, 3: Results
  bool _isAnalyzing = false;
  bool _isLoadingGpt = false;
  String? _gptReport;

  String? _skinType;
  String? _concern;
  String? _environment;

  static const _skinTypes = [
    {'title': 'Oily Skin', 'desc': 'Excess sebum, shiny T-zone, enlarged pores'},
    {'title': 'Dry Skin', 'desc': 'Tightness, flakiness, rough texture, dehydration'},
    {'title': 'Combination', 'desc': 'Oily T-zone, dry or normal cheeks'},
    {'title': 'Sensitive Skin', 'desc': 'Prone to redness, burning, or irritation'},
    {'title': 'Normal Skin', 'desc': 'Balanced hydration, smooth, minimal blemishes'},
  ];

  static const _concerns = [
    {'title': 'Acne & Blemishes', 'desc': 'Breakouts, clogged pores, blackheads'},
    {'title': 'Hyperpigmentation', 'desc': 'Dark spots, acne scars, uneven tone'},
    {'title': 'Fine Lines & Aging', 'desc': 'Loss of elasticity, wrinkles, dryness'},
    {'title': 'Redness & Irritation', 'desc': 'Rosacea tendency, damaged skin barrier'},
    {'title': 'Dullness', 'desc': 'Lack of glow, tired appearance, sallow skin'},
  ];

  static const _environments = [
    {'title': 'Urban / Polluted', 'desc': 'High exposure to city pollution and exhaust'},
    {'title': 'Dry & Cold Climate', 'desc': 'Low humidity, harsh winds, heater dryness'},
    {'title': 'Hot & Humid', 'desc': 'High humidity, increased sweat and sebum'},
    {'title': 'Indoor AC / Heating', 'desc': 'Artificial dry air throughout the workday'},
  ];

  SkinDiagnosis _computeDiagnosis(String skinType, String concern, String environment) {
    int score = 88;
    final List<String> morning = [];
    final List<String> night = [];
    final List<String> targetActives = [];
    final List<String> avoidActives = [];
    final List<String> keywords = [];
    String summary = '';
    String recommendation = '';

    // 1. Skin Type Logic
    switch (skinType) {
      case 'Oily Skin':
        score -= 6;
        targetActives.addAll(['Niacinamide (5-10%)', 'Salicylic Acid (BHA 2%)', 'Zinc PCA']);
        avoidActives.addAll(['Heavy mineral oils', 'Comedogenic coconut oil', 'Thick waxes']);
        keywords.addAll(['effaclar', 'salicylic', 'zinc', 'niacinamide', 'cleanser']);
        summary = 'High sebum activity detected with tendency towards congested follicles and shine.';
        break;
      case 'Dry Skin':
        score -= 8;
        targetActives.addAll(['Hyaluronic Acid', 'Ceramides 1, 3, 6-II', 'Glycerin', 'Squalane']);
        avoidActives.addAll(['Denatured Alcohol', 'Harsh SLS Foaming Agents', 'Over-exfoliating acids']);
        keywords.addAll(['moisturizing', 'cerave', 'hyaluronic', 'cream', 'cleanser']);
        summary = 'Compromised moisture barrier with accelerated transepidermal water loss (TEWL).';
        break;
      case 'Sensitive Skin':
        score -= 10;
        targetActives.addAll(['Centella Asiatica', 'Panthenol (Pro-Vitamin B5)', 'Ceramides']);
        avoidActives.addAll(['Synthetic Fragrance / Parfum', 'Drying Alcohols', 'High % Glycolic Acid']);
        keywords.addAll(['cerave', 'hyaluronic', 'cleanser', 'rose']);
        summary = 'Reactive stratum corneum requiring hypoallergenic soothing and anti-inflammatory care.';
        break;
      case 'Combination':
        score -= 4;
        targetActives.addAll(['Hyaluronic Acid', 'Niacinamide', 'Light Ceramides']);
        avoidActives.addAll(['Heavy occlusive creams on T-zone']);
        keywords.addAll(['niacinamide', 'hyaluronic', 'cleanser', 'cream']);
        summary = 'Dual-zone imbalance: elevated lipid secretion in the T-zone with normal to dry cheeks.';
        break;
      case 'Normal Skin':
      default:
        score += 4;
        targetActives.addAll(['Vitamin C', 'Hyaluronic Acid', 'Peptides']);
        avoidActives.addAll(['Aggressive peeling treatments']);
        keywords.addAll(['glow', 'vitamin c', 'hyaluronic', 'moisturizing']);
        summary = 'Well-balanced lipid/moisture ratio with healthy baseline epidermal barrier.';
        break;
    }

    // 2. Concern Logic
    switch (concern) {
      case 'Acne & Blemishes':
        score -= 6;
        keywords.addAll(['effaclar', 'salicylic', 'zinc', 'ordinary']);
        morning.addAll([
          'Gentle Foaming Purifying Cleanser',
          'Niacinamide 10% + Zinc 1% (Blemish Control)',
          'Oil-Free Mattifying Water Gel',
          'Non-Comedogenic Sunscreen SPF 50+',
        ]);
        night.addAll([
          'Micellar Cleansing Water (Double Cleanse)',
          'Salicylic Acid 2% Exfoliating BHA Treatment',
          'Effaclar Duo Dual Action Treatment Cream',
          'Lightweight Barrier Soothing Fluid',
        ]);
        recommendation = 'Focus on dissolving keratin plugs and regulating sebum with BHA and Zinc without stripping healthy skin lipids.';
        break;

      case 'Hyperpigmentation':
        score -= 4;
        targetActives.add('Vitamin C (L-Ascorbic Acid)');
        keywords.addAll(['vitamin c', 'glow', 'ordinary', 'niacinamide']);
        morning.addAll([
          'Gentle Hydrating Cleanser',
          'Vitamin C 15% Glow Antioxidant Serum',
          'Light Barrier Moisturizer',
          'Strict Broad-Spectrum Sunscreen SPF 50+ (Prevents UV darkening)',
        ]);
        night.addAll([
          'Nourishing Cleansing Balm',
          'Gentle Facial Cleanser',
          'Niacinamide + Alpha Arbutin Brightening Serum',
          'Restorative Night Cream with Ceramides',
        ]);
        recommendation = 'Inhibit tyrosinase activity to fade dark spots while shielding against melanin stimulation with mandatory daily SPF.';
        break;

      case 'Fine Lines & Aging':
        score -= 4;
        targetActives.addAll(['Retinol (Vitamin A)', 'Peptides', 'Ceramides']);
        keywords.addAll(['cerave', 'moisturizing', 'cream', 'argan', 'hyaluronic']);
        morning.addAll([
          'Hydrating Cream Cleanser',
          'Hyaluronic Acid 2% Multi-Depth Hydration',
          'Ceramide Protective Moisturizing Cream',
          'Anti-Aging UV Defense SPF 50+',
        ]);
        night.addAll([
          'Nourishing Cleansing Oil',
          'Gentle Hydrating Cleanser',
          'Gentle Retinol Turnover Serum (Start 2x/week)',
          'Rich Ceramide Repair Night Balm',
        ]);
        recommendation = 'Boost cellular turnover with Retinol at night and reinforce collagen matrix with peptides and deep ceramide hydration.';
        break;

      case 'Redness & Irritation':
        score -= 8;
        targetActives.addAll(['Panthenol', 'Ceramides', 'Centella']);
        keywords.addAll(['cerave', 'moisturizing', 'hyaluronic', 'cleanser']);
        morning.addAll([
          'Lukewarm Water Splash or Non-Foaming Cleanser',
          'Hyaluronic Acid & Centella Soothing Serum',
          'Barrier Restoring Ceramide Cream',
          '100% Mineral Physical Sunscreen SPF 50+',
        ]);
        night.addAll([
          'Ultra-Gentle Cleansing Milk',
          'Barrier Repair Ceramide Moisturizing Cream',
          'Soothing Panthenol Lip & Cheek Balm',
        ]);
        recommendation = 'Eliminate all active acids and fragrances. Prioritize barrier lipid restoration with ceramides and calming agents.';
        break;

      case 'Dullness':
      default:
        score -= 3;
        targetActives.addAll(['Vitamin C 15%', 'Niacinamide', 'Hyaluronic Acid']);
        keywords.addAll(['vitamin c', 'glow', 'ordinary', 'rose']);
        morning.addAll([
          'Energizing Gentle Gel Cleanser',
          'Vitamin C 15% Glow Booster Serum',
          'Hydrating Dewy Finish Cream',
          'Luminizing Broad Spectrum SPF 50+',
        ]);
        night.addAll([
          'Cleansing Oil (Dissolves impurities & dullness)',
          'Gentle Hydrating Cleanser',
          'Hyaluronic Acid 2% + B5 Serum on damp skin',
          'Overnight Radiance Repair Cream',
        ]);
        recommendation = 'Neutralize oxidative stress with potent Vitamin C and flood stratum corneum with humectants for an instant glass-skin glow.';
        break;
    }

    // 3. Environmental Factor
    switch (environment) {
      case 'Urban / Polluted':
        score -= 3;
        recommendation += ' Due to city smog and airborne particulates, double-cleansing in the evening is mandatory to prevent oxidative aging.';
        break;
      case 'Dry & Cold Climate':
        score -= 4;
        recommendation += ' Cold winds strip lipids rapidly; apply hyaluronic serum strictly on damp skin followed by an occlusive cream.';
        break;
      case 'Hot & Humid':
        recommendation += ' Switch to water-gel textures to avoid pore clogging during sweat and high sebum hours.';
        break;
      case 'Indoor AC / Heating':
        score -= 3;
        recommendation += ' Continuous AC/heating leaches epidermal moisture; reapply light hydration or facial mist during the day.';
        break;
    }

    return SkinDiagnosis(
      healthScore: score.clamp(68, 97),
      conditionSummary: summary,
      keyRecommendation: recommendation,
      morningRoutine: morning,
      nightRoutine: night,
      targetActives: targetActives,
      avoidActives: avoidActives,
      keywords: keywords,
    );
  }

  void _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _gptReport = null;
    });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _step = 3;
      });
    }
  }

  Future<void> _fetchGptReport(List<Product> catalog) async {
    setState(() => _isLoadingGpt = true);
    try {
      final report = await AiService.instance.analyzeSkinProfileWithGpt(
        skinType: _skinType ?? 'Normal Skin',
        primaryConcern: _concern ?? 'Dullness',
        environment: _environment ?? 'Urban / Polluted',
        catalog: catalog,
      );
      if (mounted) {
        setState(() {
          _isLoadingGpt = false;
          _gptReport = report;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGpt = false;
          _gptReport = 'Could not generate AI report: $e';
        });
      }
    }
  }

  List<Product> _getRecommendedProducts(List<Product> allProducts, List<String> keywords) {
    if (allProducts.isEmpty) return [];

    // Filter skincare first
    final skincare = allProducts.where((p) => p.category.toLowerCase() == 'skincare').toList();
    final pool = skincare.isNotEmpty ? skincare : allProducts;

    final scored = pool.map((p) {
      int matchCount = 0;
      final text = '${p.name} ${p.brand} ${p.description} ${p.ingredients.join(" ")}'.toLowerCase();
      for (final kw in keywords) {
        if (text.contains(kw.toLowerCase())) {
          matchCount += 3;
        }
      }
      return MapEntry(p, matchCount);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: colors.primary, size: 20),
            const SizedBox(width: 6),
            Text(
              'AI Skin Advisor',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: colors.text),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.primary),
            tooltip: 'ChatGPT Settings',
            onPressed: () => AiSettingsDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _isAnalyzing
            ? _buildAnalyzingState(colors)
            : _step < 3
                ? _buildQuizStep(colors, isDark)
                : _buildResultsState(productsAsync, colors, isDark),
      ),
    );
  }

  Widget _buildAnalyzingState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 24),
          Text(
            'Analyzing your skin profile...',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matching dermatological formulas & ingredient safety...',
            style: GoogleFonts.poppins(fontSize: 12, color: colors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStep(AppThemeColors colors, bool isDark) {
    final title = _step == 0
        ? 'What is your Skin Type?'
        : _step == 1
            ? 'What is your primary Concern?'
            : 'What is your Environment?';

    final options = _step == 0
        ? _skinTypes
        : _step == 1
            ? _concerns
            : _environments;

    final selected = _step == 0
        ? _skinType
        : _step == 1
            ? _concern
            : _environment;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.primary
                        : (isDark ? colors.cardBackground : AppColors.cream),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          Text(
            'Step ${_step + 1} of 3',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = options[i];
                final isSel = selected == item['title'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_step == 0) _skinType = item['title'];
                      if (_step == 1) _concern = item['title'];
                      if (_step == 2) _environment = item['title'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSel
                          ? colors.primary.withValues(alpha: 0.18)
                          : colors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel ? colors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSel ? Icons.check_circle : Icons.circle_outlined,
                          color: isSel ? colors.primary : colors.mutedText,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                ),
                              ),
                              Text(
                                item['desc']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: colors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selected == null
                  ? null
                  : () {
                      if (_step < 2) {
                        setState(() => _step++);
                      } else {
                        _runAnalysis();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _step == 2 ? 'Generate AI Analysis' : 'Next Step →',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState(
    AsyncValue<List<Product>> productsAsync,
    AppThemeColors colors,
    bool isDark,
  ) {
    final diagnosis = _computeDiagnosis(
      _skinType ?? 'Normal Skin',
      _concern ?? 'Dullness',
      _environment ?? 'Urban / Polluted',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dynamic Health Report Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                  colors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Skin Health Report',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${diagnosis.healthScore}% Score',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF141D1A) : AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Profile: $_skinType  •  Target: $_concern',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  diagnosis.conditionSummary,
                  style: GoogleFonts.poppins(fontSize: 12, height: 1.5, color: colors.text),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.cardBackground.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 18, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diagnosis.keyRecommendation,
                          style: GoogleFonts.poppins(fontSize: 11, height: 1.5, color: colors.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Target Actives vs Avoid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Text('Recommended Actives', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: colors.text)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final a in diagnosis.targetActives)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• $a', style: GoogleFonts.poppins(fontSize: 11, color: colors.text)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                          SizedBox(width: 6),
                          Text('Ingredients to Avoid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final av in diagnosis.avoidActives)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• $av', style: GoogleFonts.poppins(fontSize: 11, color: colors.text)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Dynamic Daily Routine
          Text(
            'Personalized Daily Routine',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 10),
          _routineCard('Morning Routine (AM)', diagnosis.morningRoutine, colors),
          const SizedBox(height: 10),
          _routineCard('Night Routine (PM)', diagnosis.nightRoutine, colors),
          const SizedBox(height: 20),

          // 3.5. ChatGPT Live Consultation Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.psychology, color: colors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deep ChatGPT Skincare Protocol',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          Text(
                            'تحليل واستشارة سريرية بالذكاء الاصطناعي',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: colors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_gptReport != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _gptReport!,
                      style: GoogleFonts.poppins(fontSize: 12, height: 1.6, color: colors.text),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingGpt
                            ? null
                            : () {
                                final catalog = productsAsync.value ?? [];
                                _fetchGptReport(catalog);
                              },
                        icon: _isLoadingGpt
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          _gptReport == null ? 'Generate ChatGPT Protocol' : 'Refresh AI Protocol',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const IngredientCheckerScreen()),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Live Chat', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.primary),
                        foregroundColor: colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Targeted Store Products
          Text(
            'Tailored Store Products for You',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 10),

          productsAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
            error: (_, __) => const SizedBox(),
            data: (allProducts) {
              final list = _getRecommendedProducts(allProducts, diagnosis.keywords);
              return SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
                      ),
                      child: Container(
                        width: 155,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Center(child: ProductImage(path: p.image, size: 85))),
                            const SizedBox(height: 4),
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                            Text(
                              p.brand,
                              style: GoogleFonts.poppins(fontSize: 10, color: colors.mutedText),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.price.toStringAsFixed(0)} DA',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 5. Retake Quiz
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Retake AI Quiz with Different Choices',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routineCard(String title, List<String> steps, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: colors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: GoogleFonts.poppins(fontSize: 12, color: colors.text),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
