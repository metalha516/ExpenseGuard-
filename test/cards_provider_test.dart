import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/features/cards/providers/cards_provider.dart';

void main() {
  group('CardsNotifier Unit Tests', () {
    test('initial state loads 2 cards and card-specific transactions', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(cardsProvider);
      expect(state.cards.length, 2);
      expect(state.selectedCardIndex, 0);

      // Card 1
      final card1 = state.selectedCard;
      expect(card1.last4, '4289');
      expect(card1.isVirtual, false);
      expect(card1.isFrozen, false);
      expect(card1.monthlyLimit, 5000.0);
      expect(card1.currentSpend, 2840.0);
      expect(card1.remainingLimit, 2160.0);

      // Card 1 transactions
      expect(state.selectedCardTransactions.length, 2);
      expect(state.selectedCardTransactions.first.merchant, 'Blue Bottle Coffee');
    });

    test('selectCard updates active card and transaction feed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cardsProvider.notifier);
      notifier.selectCard(1);

      final state = container.read(cardsProvider);
      expect(state.selectedCardIndex, 1);
      expect(state.selectedCard.last4, '9912');
      expect(state.selectedCard.isVirtual, true);
      expect(state.selectedCard.isFrozen, true);

      // Card 2 transactions
      expect(state.selectedCardTransactions.length, 2);
      expect(state.selectedCardTransactions.first.merchant, 'AWS Cloud Services');
    });

    test('toggleFreeze mutates isFrozen on target card', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cardsProvider.notifier);

      // Freeze Card 1
      expect(container.read(cardsProvider).cards[0].isFrozen, false);
      notifier.toggleFreeze('card-01');
      expect(container.read(cardsProvider).cards[0].isFrozen, true);

      // Unfreeze Card 1
      notifier.toggleFreeze('card-01');
      expect(container.read(cardsProvider).cards[0].isFrozen, false);

      // Unfreeze Card 2
      expect(container.read(cardsProvider).cards[1].isFrozen, true);
      notifier.toggleFreeze('card-02');
      expect(container.read(cardsProvider).cards[1].isFrozen, false);
    });

    test('updateMonthlyLimit adjusts card budget', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cardsProvider.notifier);
      notifier.updateMonthlyLimit('card-01', 7500.0);

      final card = container.read(cardsProvider).cards[0];
      expect(card.monthlyLimit, 7500.0);
      expect(card.remainingLimit, 7500.0 - 2840.0);
    });

    test('requestNewCard adds a new card and switches selection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cardsProvider.notifier);
      notifier.requestNewCard(
        cardholderName: 'Sarah Jenkins',
        isVirtual: true,
        monthlyLimit: 3000.0,
        cardLabel: 'Dev Subscriptions',
      );

      final state = container.read(cardsProvider);
      expect(state.cards.length, 3);
      expect(state.selectedCardIndex, 2);
      expect(state.selectedCard.cardholderName, 'Sarah Jenkins');
      expect(state.selectedCard.isVirtual, true);
      expect(state.selectedCard.monthlyLimit, 3000.0);
      expect(state.selectedCard.displayName, 'Dev Subscriptions');
    });
  });
}
