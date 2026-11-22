import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import 'ingredient_rules.dart';

class IngredientCheckerScreen extends StatefulWidget {
  const IngredientCheckerScreen({super.key});

  @override
  State<IngredientCheckerScreen> createState() =>
      _IngredientCheckerScreenState();
}

class _IngredientCheckerScreenState extends State<IngredientCheckerScreen> {
  String? _first;
  String? _second;
  String? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ingredient Checker',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 26, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Check if two ingredients can be used together',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.mutedText)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _first,
                isExpanded: true,
                decoration:
                const InputDecoration(hintText: 'First ingredient'),
                items: [
                  for (final i in ingredientList)
                    DropdownMenuItem(value: i, child: Text(i)),
                ],
                onChanged: (v) => setState(() => _first = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _second,
                isExpanded: true,
                decoration:
                const InputDecoration(hintText: 'Second ingredient'),
                items: [
                  for (final i in ingredientList)
                    DropdownMenuItem(value: i, child: Text(i)),
                ],
                onChanged: (v) => setState(() => _second = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_first == null || _second == null)
                    ? null
                    : () => setState(
                        () => _result = checkPair(_first!, _second!)),
                child: const Text('Check'),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_result!,
                      style: GoogleFonts.poppins(fontSize: 13, height: 1.6)),
                ),
              ],
              const SizedBox(height: 24),
              Text('Safe ingredients',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              for (final e in safePairs.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text('• ${e.key}: ${e.value}',
                      style: GoogleFonts.poppins(fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}