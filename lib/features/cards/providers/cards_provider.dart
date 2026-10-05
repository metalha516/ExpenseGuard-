import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/corporate_card.dart';
import 'package:expense_guard/models/transaction.dart';

/// Immutable state for the Corporate Cards screen.
@immutable
class CardsState {
  const CardsState({
    required this.cards,
    this.selectedCardIndex = 0,
    required this.transactions,
    this.isLoading = false,
  });

  final List<CorporateCard> cards;
  final int selectedCardIndex;
  final List<Transaction> transactions;
  final bool isLoading;

  /// The currently active card in the carousel.
  CorporateCard get selectedCard =>
      cards.isNotEmpty ? cards[selectedCardIndex.clamp(0, cards.length - 1)] : _emptyCard;

  /// Transactions belonging to the currently selected card.
  List<Transaction> get selectedCardTransactions =>
      transactions.where((tx) => tx.cardLast4 == selectedCard.last4).toList();

  static const _emptyCard = CorporateCard(
    id: 'empty',
    cardholderName: '',
    last4: '0000',
    expiryMonth: 1,
    expiryYear: 2030,
    monthlyLimit: 1000,
  );

  CardsState copyWith({
    List<CorporateCard>? cards,
    int? selectedCardIndex,
    List<Transaction>? transactions,
    bool? isLoading,
  }) {
    return CardsState(
      cards: cards ?? this.cards,
      selectedCardIndex: selectedCardIndex ?? this.selectedCardIndex,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardsState &&
          runtimeType == other.runtimeType &&
          listEquals(cards, other.cards) &&
          selectedCardIndex == other.selectedCardIndex &&
          listEquals(transactions, other.transactions) &&
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(cards),
        selectedCardIndex,
        Object.hashAll(transactions),
        isLoading,
      );
}

/// Riverpod Notifier managing Corporate Cards carousel, freeze toggles,
/// limit adjustments, and new card provisioning.
class CardsNotifier extends Notifier<CardsState> {
  @override
  CardsState build() {
    return CardsState(
      cards: _buildInitialCards(),
      transactions: _buildInitialTransactions(),
    );
  }

  static List<CorporateCard> _buildInitialCards() {
    return [
      // 1. Physical Corporate Visa (Stitch screen 0afa9545e55b4f2b8d2b452f34b5ff36)
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

      // 2. Virtual Software Subscriptions Card (Stitch screen 0afa9545e55b4f2b8d2b452f34b5ff36)
      const CorporateCard(
        id: 'card-02',
        cardholderName: 'Alex Johnson',
        last4: '9912',
        brand: 'Visa',
        cardLabel: 'Software Subs (Virtual)',
        expiryMonth: 8,
        expiryYear: 2025,
        monthlyLimit: 1500.0,
        currentSpend: 49.99,
        currency: 'USD',
        isVirtual: true,
        isFrozen: true, // Initially shown frozen in Stitch reference
        cardColorHex: '#206A57',
      ),
    ];
  }

  static List<Transaction> _buildInitialTransactions() {
    final now = DateTime.now();

    return [
      // Transactions for Card 4289
      Transaction(
        id: 'tx-card-01',
        merchant: 'Blue Bottle Coffee',
        amount: 14.50,
        category: 'Meals & Dining',
        timestamp: now.subtract(const Duration(hours: 3)),
        status: TransactionStatus.cleared,
        cardLast4: '4289',
        iconName: 'local_cafe',
        receiptAttached: true,
      ),
      Transaction(
        id: 'tx-card-02',
        merchant: 'Delta Airlines',
        amount: 450.00,
        category: 'Travel & Lodging',
        timestamp: now.subtract(const Duration(days: 1)),
        status: TransactionStatus.cleared,
        cardLast4: '4289',
        iconName: 'flight',
        receiptAttached: true,
      ),

      // Transactions for Card 9912
      Transaction(
        id: 'tx-card-03',
        merchant: 'AWS Cloud Services',
        amount: 49.99,
        category: 'Software Subscription',
        timestamp: now.subtract(const Duration(days: 2)),
        status: TransactionStatus.cleared,
        cardLast4: '9912',
        iconName: 'cloud',
        receiptAttached: true,
      ),
      Transaction(
        id: 'tx-card-04',
        merchant: 'GitHub Enterprise',
        amount: 42.00,
        category: 'Software Subscription',
        timestamp: now.subtract(const Duration(days: 5)),
        status: TransactionStatus.cleared,
        cardLast4: '9912',
        iconName: 'code',
        receiptAttached: true,
      ),
    ];
  }

  /// Change active card index in carousel.
  void selectCard(int index) {
    if (index >= 0 && index < state.cards.length) {
      state = state.copyWith(selectedCardIndex: index);
    }
  }

  /// Toggle frozen status of a card by ID.
  void toggleFreeze(String cardId) {
    state = state.copyWith(
      cards: state.cards.map((c) {
        if (c.id == cardId) {
          return c.copyWith(isFrozen: !c.isFrozen);
        }
        return c;
      }).toList(),
    );
  }

  /// Set frozen status explicitly.
  void setFreeze(String cardId, bool isFrozen) {
    state = state.copyWith(
      cards: state.cards.map((c) {
        if (c.id == cardId) {
          return c.copyWith(isFrozen: isFrozen);
        }
        return c;
      }).toList(),
    );
  }

  /// Update monthly spending limit for a card.
  void updateMonthlyLimit(String cardId, double newLimit) {
    if (newLimit < 0 || newLimit.isNaN || newLimit.isInfinite) return;

    state = state.copyWith(
      cards: state.cards.map((c) {
        if (c.id == cardId) {
          return c.copyWith(monthlyLimit: newLimit);
        }
        return c;
      }).toList(),
    );
  }

  /// Provision and add a new corporate card.
  void requestNewCard({
    required String cardholderName,
    required bool isVirtual,
    double monthlyLimit = 2500.0,
    String? cardLabel,
  }) {
    final nextIdNum = state.cards.length + 1;
    final randomLast4 = '${(1000 + nextIdNum * 137) % 9000 + 1000}';
    final now = DateTime.now();

    final newCard = CorporateCard(
      id: 'card-0$nextIdNum',
      cardholderName: cardholderName.trim().isNotEmpty ? cardholderName.trim() : 'Alex Johnson',
      last4: randomLast4,
      brand: 'Visa',
      cardLabel: cardLabel ?? (isVirtual ? 'Virtual Requisition' : 'Physical Corporate'),
      expiryMonth: now.month,
      expiryYear: now.year + 3,
      monthlyLimit: monthlyLimit,
      currentSpend: 0.0,
      isVirtual: isVirtual,
      isFrozen: false,
      cardColorHex: isVirtual ? '#C7CEEA' : '#FFDAC1',
    );

    final updatedCards = [...state.cards, newCard];
    state = state.copyWith(
      cards: updatedCards,
      selectedCardIndex: updatedCards.length - 1,
    );
  }

  /// Reset to initial state.
  void reset() {
    state = CardsState(
      cards: _buildInitialCards(),
      transactions: _buildInitialTransactions(),
    );
  }
}

/// Global provider exposing Cards state and actions.
final cardsProvider =
    NotifierProvider<CardsNotifier, CardsState>(CardsNotifier.new);
