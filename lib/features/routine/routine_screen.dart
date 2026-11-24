import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';

class RoutineStep {
  final String id;
  String title;
  bool isCompleted;

  RoutineStep({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  bool _isMorning = true;

  final List<RoutineStep> _morningSteps = [
    RoutineStep(id: 'm1', title: 'Facial Cleanser', isCompleted: true),
    RoutineStep(id: 'm2', title: 'Hydrating Toner', isCompleted: true),
    RoutineStep(id: 'm3', title: 'Vitamin C Serum', isCompleted: false),
    RoutineStep(id: 'm4', title: 'Light Moisturizer', isCompleted: false),
    RoutineStep(id: 'm5', title: 'Sunscreen (SPF 50+)', isCompleted: false),
  ];

  final List<RoutineStep> _nightSteps = [
    RoutineStep(id: 'n1', title: 'Cleansing Oil / Water', isCompleted: true),
    RoutineStep(id: 'n2', title: 'Gentle Cleanser', isCompleted: false),
    RoutineStep(id: 'n3', title: 'Exfoliating Serum / Retinol', isCompleted: false),
    RoutineStep(id: 'n4', title: 'Nourishing Night Cream', isCompleted: false),
    RoutineStep(id: 'n5', title: 'Eye Cream & Lip Mask', isCompleted: false),
  ];

  List<RoutineStep> get _currentSteps => _isMorning ? _morningSteps : _nightSteps;

  void _showAddStepDialog() {
    final controller = TextEditingController();
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          s.t('Add Routine Step'),
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: s.t('Step name (e.g., Face Oil)'),
            fillColor: colors.inputFill,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.t('Cancel'), style: GoogleFonts.poppins(color: colors.mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _currentSteps.add(RoutineStep(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: text,
                    isCompleted: false,
                  ));
                });
              }
              Navigator.of(context).pop();
            },
            child: Text(s.t('Add'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _currentSteps;
    final total = steps.length;
    final doneCount = steps.where((s) => s.isCompleted).length;
    final double progress = total > 0 ? (doneCount / total).clamp(0.0, 1.0) : 0.0;
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان والزر لإضافة خطوة جديدة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLogo(size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.t('Daily Routine'),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.t('Track your skincare steps every day'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: colors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddStepDialog,
                    icon: Icon(Icons.add_circle, color: colors.primary, size: 32),
                    tooltip: s.t('Add Step'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // زر التبديل بين الصباح والليل
              Row(
                children: [
                  Expanded(
                    child: _routineTab(
                      label: s.t('Morning Routine'),
                      icon: Icons.wb_sunny_outlined,
                      activeIcon: Icons.wb_sunny,
                      activeColor: Colors.amber.shade700,
                      isMorningTab: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _routineTab(
                      label: s.t('Night Routine'),
                      icon: Icons.nightlight_round_outlined,
                      activeIcon: Icons.nightlight_round,
                      activeColor: Colors.indigo.shade600,
                      isMorningTab: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // بطاقة النسبة المئوية والتطور
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.t('Progress'),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        Text(
                          s.tf('{done} of {total} completed ({percent}%)', {
                            'done': '$doneCount',
                            'total': '$total',
                            'percent': '${(progress * 100).toInt()}',
                          }),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: colors.background,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // قائمة الخطوات اليومية
              Expanded(
                child: total == 0
                    ? Center(
                        child: Text(
                          s.t('No routine steps yet.\nTap + to add one!'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: colors.mutedText),
                        ),
                      )
                    : ListView.separated(
                        itemCount: total,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final step = steps[index];

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              clipBehavior: Clip.antiAlias,
                              child: CheckboxListTile(
                                value: step.isCompleted,
                                activeColor: colors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text(
                                  s.tf('Step {n}: {title}', {
                                    'n': '${index + 1}',
                                    'title': s.t(step.title),
                                  }),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: step.isCompleted ? colors.mutedText : colors.text,
                                    decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                secondary: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      steps.removeAt(index);
                                    });
                                  },
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    step.isCompleted = val ?? false;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routineTab({
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required Color activeColor,
    required bool isMorningTab,
  }) {
    final isSelected = _isMorning == isMorningTab;
    final colors = AppThemeColors.of(context);

    return GestureDetector(
      onTap: () => setState(() => _isMorning = isMorningTab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.white : colors.text,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.white : colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
