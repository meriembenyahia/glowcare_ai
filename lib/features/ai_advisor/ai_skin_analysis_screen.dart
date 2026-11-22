import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
import '../shop/product.dart';
import '../shop/product_details_screen.dart';
import '../shop/product_provider.dart';

class AiSkinAnalysisScreen extends ConsumerStatefulWidget {
  const AiSkinAnalysisScreen({super.key});

  @override
  ConsumerState<AiSkinAnalysisScreen> createState() => _AiSkinAnalysisScreenState();
}

class _AiSkinAnalysisScreenState extends ConsumerState<AiSkinAnalysisScreen> {
  int _step = 0; // 0: Skin Type, 1: Concern, 2: Environment, 3: Results
  bool _isAnalyzing = false;

  String? _skinType;
  String? _concern;
  String? _environment;

  static const _skinTypes = [
    {'title': 'Oily Skin', 'desc': 'Excess sebum, shiny T-zone, enlarged pores'},
    {'title': 'Dry Skin', 'desc': 'Tightness, flakiness, rough texture'},
    {'title': 'Combination', 'desc': 'Oily T-zone, dry or normal cheeks'},
    {'title': 'Sensitive Skin', 'desc': 'Prone to redness, burning, or irritation'},
    {'title': 'Normal Skin', 'desc': 'Balanced hydration, smooth, minimal blemishes'},
  ];

  static const _concerns = [
    {'title': 'Acne & Blemishes', 'desc': 'Breakouts, clogged pores, blackheads'},
    {'title': 'Hyperpigmentation', 'desc': 'Dark spots, acne scars, uneven tone'},
    {'title': 'Fine Lines & Aging', 'desc': 'Loss of elasticity, wrinkles, dryness'},
    {'title': 'Redness & Irritation', 'desc': 'Rosacea tendency, sensitive barrier'},
    {'title': 'Dullness', 'desc': 'Lack of glow, tired appearance'},
  ];

  static const _environments = [
    {'title': 'Urban / Polluted', 'desc': 'High exposure to city pollution'},
    {'title': 'Dry & Cold Climate', 'desc': 'Low humidity, harsh winds'},
    {'title': 'Hot & Humid', 'desc': 'High humidity, increased sweat'},
    {'title': 'Indoor AC / Heating', 'desc': 'Artificial dry air throughout the day'},
  ];

  void _runAnalysis() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _step = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.deepGreen, size: 20),
            const SizedBox(width: 6),
            Text(
              'AI Skin Advisor',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: SafeArea(
        child: _isAnalyzing
            ? _buildAnalyzingState()
            : _step < 3
                ? _buildQuizStep()
                : _buildResultsState(productsAsync),
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.deepGreen),
          const SizedBox(height: 24),
          Text(
            'Analyzing your skin profile...',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matching dermatological formulas & ingredient safety...',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStep() {
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
          // شريط التقدم فـ الاختبار
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.deepGreen : AppColors.cream,
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
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
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
                      color: isSel ? AppColors.sageGreen.withValues(alpha: 0.15) : AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel ? AppColors.deepGreen : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSel ? Icons.check_circle : Icons.circle_outlined,
                          color: isSel ? AppColors.deepGreen : AppColors.mutedText,
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
                                  color: AppColors.darkText,
                                ),
                              ),
                              Text(
                                item['desc']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.mutedText,
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

          // زر المتابعة (Next)
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
                backgroundColor: AppColors.deepGreen,
                foregroundColor: AppColors.white,
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

  Widget _buildResultsState(AsyncValue<List<Product>> productsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة نتيجة التشخيص
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sageGreen.withValues(alpha: 0.3),
                  AppColors.sageGreen.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
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
                        color: AppColors.darkText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.deepGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '92% Score',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your barrier requires targeted hydration with barrier-restoring ceramides and Niacinamide to balance oil production without clogging pores.',
                  style: GoogleFonts.poppins(fontSize: 12, height: 1.5, color: AppColors.darkText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // الروتين الموصى به من الذكاء الاصطناعي
          Text(
            'AI Recommended Daily Routine',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          _routineCard('Morning Routine', [
            'Gentle Hydrating Cleanser',
            'Niacinamide 10% + Zinc 1% Serum',
            'Broad Spectrum Sunscreen SPF 50+',
          ]),
          const SizedBox(height: 10),
          _routineCard('Night Routine', [
            'Oil-based Cleansing Balm',
            'Salicylic Acid / BHA Treatment',
            'Ceramide Barrier Night Cream',
          ]),
          const SizedBox(height: 20),

          // المنتجات المقترحة من الكتالوج
          Text(
            'Recommended Products for You',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),

          productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.deepGreen)),
            error: (_, __) => const SizedBox(),
            data: (products) {
              final list = products.take(4).toList();
              return SizedBox(
                height: 215,
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
                        width: 145,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
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
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text('${p.price.toStringAsFixed(0)} DA',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepGreen)),
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

          // زر إعادة الاختبار
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.deepGreen),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Retake AI Quiz',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routineCard(String title, List<String> steps) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 6),
          for (final s in steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: AppColors.sageGreen),
                  const SizedBox(width: 8),
                  Text(s, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
