import 'package:expense_guard/models/corporate_card.dart';

/// Repository managing corporate credit and virtual cards.
class CardsRepository {
  CardsRepository({List<CorporateCard>? initialData})
      : _cards = initialData ?? _buildDefaultCards();

  final List<CorporateCard> _cards;

  /// Fetch all corporate cards.
  Future<List<CorporateCard>> getCards() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return List.unmodifiable(_cards);
  }

  /// Fetch a single card by ID.
  Future<CorporateCard?> getCardById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Freeze or unfreeze a corporate card.
  Future<CorporateCard> setFreezeStatus(String id, bool isFrozen) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final index = _cards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final updated = _cards[index].copyWith(isFrozen: isFrozen);
      _cards[index] = updated;
      return updated;
    }
    throw StateError('Card with id $id not found.');
  }

  /// Update the monthly spending limit.
  Future<CorporateCard> updateMonthlyLimit(String id, double newLimit) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final index = _cards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final updated = _cards[index].copyWith(monthlyLimit: newLimit);
      _cards[index] = updated;
      return updated;
    }
    throw StateError('Card with id $id not found.');
  }

  /// Provision a new virtual or physical corporate card.
  Future<CorporateCard> requestNewCard({
    required String cardholderName,
    required bool isVirtual,
    required double monthlyLimit,
    required String cardLabel,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final nextId = 'card-0${_cards.length + 1}';
    final randomLast4 = (1000 + (_cards.length * 37) % 9000).toString();

    final newCard = CorporateCard(
      id: nextId,
      cardholderName: cardholderName,
      last4: randomLast4,
      brand: 'Visa',
      cardLabel: cardLabel,
      expiryMonth: 12,
      expiryYear: DateTime.now().year + 3,
      monthlyLimit: monthlyLimit,
      currentSpend: 0.0,
      isVirtual: isVirtual,
      isFrozen: false,
      cardColorHex: isVirtual ? '#206A57' : '#0F5E4C',
    );

    _cards.add(newCard);
    return newCard;
  }

  /// Default mock cards reflecting real-world corporate fleets.
  static List<CorporateCard> _buildDefaultCards() {
    return [
      // 1. Primary Physical Corporate Card
      const CorporateCard(
        id: 'card-01',
        cardholderName: 'Alex Johnson',
        last4: '4289',
        brand: 'Visa',
        cardLabel: 'Corporate Visa',
        expiryMonth: 12,
        expiryYear: 2026,
        monthlyLimit: 5000.0,
        currentSpend: 2840.0,
        currency: 'USD',
        isVirtual: false,
        isFrozen: false,
        cardColorHex: '#0F5E4C',
      ),

      // 2. Virtual Subscriptions Card (Paused/Frozen)
      const CorporateCard(
        id: 'card-02',
        cardholderName: 'Alex Johnson',
        last4: '9912',
        brand: 'Visa',
        cardLabel: 'Software Subs (Virtual)',
        expiryMonth: 8,
        expiryYear: 2025,
        monthlyLimit: 1500.0,
        currentSpend: 1200.0,
        currency: 'USD',
        isVirtual: true,
        isFrozen: true,
        cardColorHex: '#206A57',
      ),

      // 3. Virtual Travel Stipend Card
      const CorporateCard(
        id: 'card-03',
        cardholderName: 'Alex Johnson',
        last4: '3310',
        brand: 'Visa',
        cardLabel: 'Travel Stipend (Virtual)',
        expiryMonth: 11,
        expiryYear: 2027,
        monthlyLimit: 2500.0,
        currentSpend: 845.0,
        currency: 'USD',
        isVirtual: true,
        isFrozen: false,
        cardColorHex: '#1D4E89',
      ),
    ];
  }
}
