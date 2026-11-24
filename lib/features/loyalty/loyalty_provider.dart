import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  Loyalty tier definition
// ─────────────────────────────────────────────
enum LoyaltyTier { bronze, silver, gold, platinum }

extension LoyaltyTierX on LoyaltyTier {
  String get label {
    switch (this) {
      case LoyaltyTier.bronze:   return 'Bronze';
      case LoyaltyTier.silver:   return 'Silver';
      case LoyaltyTier.gold:     return 'Gold';
      case LoyaltyTier.platinum: return 'Platinum';
    }
  }

  String get emoji {
    switch (this) {
      case LoyaltyTier.bronze:   return '🥉';
      case LoyaltyTier.silver:   return '🥈';
      case LoyaltyTier.gold:     return '🥇';
      case LoyaltyTier.platinum: return '💎';
    }
  }

  List<String> get benefits {
    switch (this) {
      case LoyaltyTier.bronze:
        return [
          'Early access to new arrivals',
          'Birthday surprise gift',
          'Free delivery on orders over 3000 DA',
        ];
      case LoyaltyTier.silver:
        return [
          'All Bronze benefits',
          '5% discount on every order',
          'Priority customer support',
          'Exclusive Silver member bundles',
        ];
      case LoyaltyTier.gold:
        return [
          'All Silver benefits',
          '10% discount on every order',
          'Free express delivery always',
          'Dedicated account manager',
          'First access to limited editions',
        ];
      case LoyaltyTier.platinum:
        return [
          'All Gold benefits',
          '15% discount on every order',
          'VIP concierge service',
          'Personalized skincare consultation',
          'Exclusive Platinum-only products',
          'Invite-only GlowCare events',
        ];
    }
  }

  int get nextTierThreshold {
    switch (this) {
      case LoyaltyTier.bronze:   return 500;
      case LoyaltyTier.silver:   return 1000;
      case LoyaltyTier.gold:     return 2000;
      case LoyaltyTier.platinum: return 2000; // already max
    }
  }

  int get currentMin {
    switch (this) {
      case LoyaltyTier.bronze:   return 0;
      case LoyaltyTier.silver:   return 500;
      case LoyaltyTier.gold:     return 1000;
      case LoyaltyTier.platinum: return 2000;
    }
  }
}

// ─────────────────────────────────────────────
//  Point history entry
// ─────────────────────────────────────────────
class PointEntry {
  final int points;
  final String reason;
  final DateTime date;

  const PointEntry({
    required this.points,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'points': points,
    'reason': reason,
    'date': date.toIso8601String(),
  };

  factory PointEntry.fromJson(Map<String, dynamic> json) => PointEntry(
    points: json['points'] as int? ?? 0,
    reason: json['reason'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
  );
}

// ─────────────────────────────────────────────
//  State class
// ─────────────────────────────────────────────
class LoyaltyState {
  final int totalPoints;
  final List<PointEntry> history;

  const LoyaltyState({
    required this.totalPoints,
    required this.history,
  });

  LoyaltyTier get tier {
    if (totalPoints >= 2000) return LoyaltyTier.platinum;
    if (totalPoints >= 1000) return LoyaltyTier.gold;
    if (totalPoints >= 500) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  /// Points earned from current order total (10 pts per 1000 DA)
  static int pointsForOrder(double orderTotal) =>
      (orderTotal / 100).floor(); // 1 point per 100 DA

  LoyaltyState copyWith({int? totalPoints, List<PointEntry>? history}) =>
      LoyaltyState(
        totalPoints: totalPoints ?? this.totalPoints,
        history: history ?? this.history,
      );
}

// ─────────────────────────────────────────────
//  Notifier
// ─────────────────────────────────────────────
class LoyaltyNotifier extends Notifier<LoyaltyState> {
  static const _keyPoints  = 'loyalty_points';
  static const _keyHistory = 'loyalty_history';

  @override
  LoyaltyState build() {
    _load();
    return const LoyaltyState(totalPoints: 0, history: []);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final pts = prefs.getInt(_keyPoints) ?? 0;
    final raw = prefs.getString(_keyHistory);
    List<PointEntry> history = [];
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          history = [
            for (final item in decoded)
              if (item is Map) PointEntry.fromJson(Map<String, dynamic>.from(item)),
          ];
        }
      } catch (_) {}
    }
    state = LoyaltyState(totalPoints: pts, history: history);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, state.totalPoints);
    await prefs.setString(
      _keyHistory,
      jsonEncode([for (final e in state.history) e.toJson()]),
    );
  }

  /// Call after each confirmed order
  Future<void> addPoints(double orderTotal, {String? orderId}) async {
    final earned = LoyaltyState.pointsForOrder(orderTotal);
    if (earned <= 0) return;
    final entry = PointEntry(
      points: earned,
      reason: 'Order${orderId != null ? ' #$orderId' : ''} — ${orderTotal.toStringAsFixed(0)} DA',
      date: DateTime.now(),
    );
    state = state.copyWith(
      totalPoints: state.totalPoints + earned,
      history: [entry, ...state.history],
    );
    await _save();
  }

  /// Redeem points (e.g. 100 pts = 100 DA discount)
  Future<bool> redeemPoints(int points) async {
    if (state.totalPoints < points) return false;
    final entry = PointEntry(
      points: -points,
      reason: 'Redeemed — $points pts discount',
      date: DateTime.now(),
    );
    state = state.copyWith(
      totalPoints: state.totalPoints - points,
      history: [entry, ...state.history],
    );
    await _save();
    return true;
  }

  /// Reset (for testing / dev console)
  Future<void> reset() async {
    state = const LoyaltyState(totalPoints: 0, history: []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPoints);
    await prefs.remove(_keyHistory);
  }
}

final loyaltyProvider =
    NotifierProvider<LoyaltyNotifier, LoyaltyState>(LoyaltyNotifier.new);
