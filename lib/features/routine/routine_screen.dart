import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';

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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Routine Step',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'Step name (e.g., Face Oil)',
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
            child: Text('Cancel', style: GoogleFonts.poppins(color: colors.mutedText)),
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
            child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Routine',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your skincare steps every day',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _showAddStepDialog,
                    icon: Icon(Icons.add_circle, color: colors.primary, size: 32),
                    tooltip: 'Add Step',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // زر التبديل بين الصباح والليل
              Row(
                children: [
                  Expanded(
                    child: _routineTab(
                      label: 'Morning Routine',
                      icon: Icons.wb_sunny_outlined,
                      activeIcon: Icons.wb_sunny,
                      activeColor: Colors.amber.shade700,
                      isMorningTab: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _routineTab(
                      label: 'Night Routine',
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
                          'Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        Text(
                          '$doneCount of $total completed (${(progress * 100).toInt()}%)',
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
                          'No routine steps yet.\nTap + to add one!',
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
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CheckboxListTile(
                              value: step.isCompleted,
                              activeColor: colors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                'Step ${index + 1}: ${step.title}',
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
