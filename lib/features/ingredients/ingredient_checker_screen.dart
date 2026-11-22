import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import 'ingredient_rules.dart';

class IngredientCheckerScreen extends StatefulWidget {
  const IngredientCheckerScreen({super.key});

  @override
  State<IngredientCheckerScreen> createState() => _IngredientCheckerScreenState();
}

class _IngredientCheckerScreenState extends State<IngredientCheckerScreen> {
  int _mode = 0; // 0: AI Full Formula Analyzer, 1: Pair Checker

  // Pair Checker state
  String? _first;
  String? _second;
  String? _pairResult;

  // AI Formula Analyzer state
  final _ingredientsController = TextEditingController();
  Map<String, dynamic>? _aiAnalysisResult;

  void _analyzeFormula() {
    final text = _ingredientsController.text.trim();
    if (text.isEmpty) return;

    final lower = text.toLowerCase();
    int score = 95;
    final List<String> actives = [];
    final List<String> warnings = [];

    if (lower.contains('niacinamide')) actives.add('Niacinamide (Brightening & Sebum Control)');
    if (lower.contains('hyaluronic acid')) actives.add('Hyaluronic Acid (Deep Hydration)');
    if (lower.contains('salicylic acid') || lower.contains('bha')) actives.add('Salicylic Acid (BHA Exfoliation)');
    if (lower.contains('retinol')) actives.add('Retinol (Anti-Aging & Turnover)');
    if (lower.contains('vitamin c') || lower.contains('ascorbic')) actives.add('Vitamin C (Antioxidant)');
    if (lower.contains('ceramide')) actives.add('Ceramides (Barrier Repair)');

    if (lower.contains('alcohol denat') || lower.contains('alcohol')) {
      score -= 15;
      warnings.add('Contains Drying Alcohol: May irritate dry or sensitive skin.');
    }
    if (lower.contains('parfum') || lower.contains('fragrance')) {
      score -= 10;
      warnings.add('Contains Fragrance: Potential allergen for sensitive skin barrier.');
    }
    if (lower.contains('retinol') && lower.contains('salicylic')) {
      score -= 20;
      warnings.add('Combining Retinol & Salicylic Acid may cause redness or irritation.');
    }

    if (actives.isEmpty) actives.add('Hydrating base ingredients detected');

    setState(() {
      _aiAnalysisResult = {
        'score': score.clamp(50, 100),
        'actives': actives,
        'warnings': warnings,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: colors.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Beauty Lab AI',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'AI Ingredient & Safety Analyzer',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colors.mutedText,
                ),
              ),
              const SizedBox(height: 16),

              // Mode Tabs
              Row(
                children: [
                  Expanded(
                    child: _modeTab(
                      label: 'AI Formula Safety',
                      icon: Icons.auto_awesome,
                      isModeZero: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _modeTab(
                      label: 'Pair Checker',
                      icon: Icons.compare_arrows,
                      isModeZero: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_mode == 0) _buildAiFormulaView(colors) else _buildPairCheckerView(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiFormulaView(AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paste Ingredient List',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ingredientsController,
          maxLines: 4,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'e.g. Water, Niacinamide, Glycerin, Salicylic Acid, Fragrance...',
            fillColor: colors.inputFill,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _analyzeFormula,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(
              'Analyze Formula Safety',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (_aiAnalysisResult != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Safety Score',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_aiAnalysisResult!['score'] as int) > 80
                            ? colors.primary
                            : Colors.amber.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_aiAnalysisResult!['score']}/100',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  'Key Actives Found:',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
                ),
                const SizedBox(height: 6),
                for (final act in (_aiAnalysisResult!['actives'] as List<String>))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(act, style: GoogleFonts.poppins(fontSize: 12, color: colors.text))),
                      ],
                    ),
                  ),

                if ((_aiAnalysisResult!['warnings'] as List<String>).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Potential Irritants & Warnings:',
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 6),
                  for (final warn in (_aiAnalysisResult!['warnings'] as List<String>))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(warn,
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent))),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPairCheckerView(AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _first,
          isExpanded: true,
          dropdownColor: colors.cardBackground,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'First ingredient',
            fillColor: colors.inputFill,
            filled: true,
          ),
          items: [
            for (final i in ingredientList)
              DropdownMenuItem(value: i, child: Text(i, style: TextStyle(color: colors.text))),
          ],
          onChanged: (v) => setState(() => _first = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _second,
          isExpanded: true,
          dropdownColor: colors.cardBackground,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'Second ingredient',
            fillColor: colors.inputFill,
            filled: true,
          ),
          items: [
            for (final i in ingredientList)
              DropdownMenuItem(value: i, child: Text(i, style: TextStyle(color: colors.text))),
          ],
          onChanged: (v) => setState(() => _second = v),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (_first == null || _second == null)
                ? null
                : () => setState(() => _pairResult = checkPair(_first!, _second!)),
            child: const Text('Check Ingredient Pair'),
          ),
        ),
        if (_pairResult != null) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _pairResult!,
              style: GoogleFonts.poppins(fontSize: 13, height: 1.6, color: colors.text),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Safe Active Combinations',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
        ),
        const SizedBox(height: 8),
        for (final e in safePairs.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text('• ${e.key}: ${e.value}', style: GoogleFonts.poppins(fontSize: 12, color: colors.mutedText)),
          ),
      ],
    );
  }

  Widget _modeTab({
    required String label,
    required IconData icon,
    required bool isModeZero,
  }) {
    final isSel = (_mode == 0) == isModeZero;
    final colors = AppThemeColors.of(context);

    return GestureDetector(
      onTap: () => setState(() => _mode = isModeZero ? 0 : 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: isSel ? colors.primary : colors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSel ? AppColors.white : colors.text, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                color: isSel ? AppColors.white : colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
