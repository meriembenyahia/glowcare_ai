import 'package:flutter_test/flutter_test.dart';
import 'package:glowcare_ai/core/services/ai_service.dart';
import 'package:glowcare_ai/features/loyalty/loyalty_provider.dart';

void main() {
  test('Loyalty tier and points calculation test', () {
    expect(LoyaltyState.pointsForOrder(1000), 10);
    expect(LoyaltyState.pointsForOrder(5000), 50);

    const bronze = LoyaltyState(totalPoints: 100, history: []);
    expect(bronze.tier, LoyaltyTier.bronze);

    const silver = LoyaltyState(totalPoints: 500, history: []);
    expect(silver.tier, LoyaltyTier.silver);

    const gold = LoyaltyState(totalPoints: 1000, history: []);
    expect(gold.tier, LoyaltyTier.gold);

    const platinum = LoyaltyState(totalPoints: 2000, history: []);
    expect(platinum.tier, LoyaltyTier.platinum);
  });

  test('AiService initial state test', () {
    final ai = AiService.instance;
    expect(ai.hasKey, false);
  });
}
