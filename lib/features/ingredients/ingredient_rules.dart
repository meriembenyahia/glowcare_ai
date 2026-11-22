const ingredientList = [
  'Retinol',
  'Vitamin C',
  'Niacinamide',
  'Hyaluronic Acid',
  'Salicylic Acid',
  'Glycolic Acid',
  'Benzoyl Peroxide',
  'Ceramides',
  'Zinc',
  'Peptides',
];

class Conflict {
  final String a;
  final String b;
  final String advice;
  const Conflict(this.a, this.b, this.advice);
}

const conflicts = [
  Conflict('Retinol', 'Vitamin C',
      'Avoid together. Use Vitamin C in the morning and Retinol at night.'),
  Conflict('Retinol', 'Salicylic Acid',
      'Too irritating together. Use on different days.'),
  Conflict('Retinol', 'Glycolic Acid',
      'Strong exfoliation, high risk of irritation. Alternate nights.'),
  Conflict('Retinol', 'Benzoyl Peroxide',
      'Benzoyl Peroxide can deactivate Retinol. Use separately.'),
  Conflict('Vitamin C', 'Glycolic Acid',
      'Both are acidic and may irritate. Use at different times.'),
];

const safePairs = {
  'Niacinamide': 'Works well with almost everything.',
  'Hyaluronic Acid': 'Safe with all ingredients.',
  'Ceramides': 'Safe, helps repair the skin barrier.',
};

String checkPair(String x, String y) {
  if (x == y) return 'Please choose two different ingredients.';
  for (final c in conflicts) {
    if ((c.a == x && c.b == y) || (c.a == y && c.b == x)) {
      return '⚠️ Not recommended: ${c.advice}';
    }
  }
  return '✅ Safe to combine.';
}