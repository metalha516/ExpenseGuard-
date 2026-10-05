import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/models/corporate_card.dart';
import 'package:expense_guard/features/cards/providers/cards_provider.dart';
import 'package:expense_guard/features/shared/presentation/skeleton_loader.dart';

/// Screen displaying Corporate Cards carousel (Physical and Virtual),
/// card freeze toggles, monthly budget limits, and card-specific transactions.
/// Based on Stitch Screen ID: 0afa9545e55b4f2b8d2b452f34b5ff36 ("Corporate Cards").
class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAdjustLimitDialog(
    BuildContext context,
    CorporateCard card,
    CardsNotifier notifier,
  ) {
    double currentLimit = card.monthlyLimit;
    final colors = context.pastelColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppTheme.marginMobile),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: colors.borderDark, width: 2.0),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.borderDark.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Adjust Spending Limit',
                      style: context.headlineMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${card.displayName} (•••• ${card.last4})',
                      style: context.metadataText.copyWith(
                        color: colors.borderDark.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        '\$${currentLimit.toStringAsFixed(0)}',
                        key: const Key('card_limit_dialog_value'),
                        style: context.displayCurrency.copyWith(
                          color: colors.borderDark,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      key: const Key('card_limit_slider'),
                      value: currentLimit,
                      min: 500,
                      max: 15000,
                      divisions: 29,
                      activeColor: colors.primarySage,
                      inactiveColor: colors.cardSurfaceAlt,
                      onChanged: (val) {
                        setModalState(() {
                          currentLimit = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$500 min', style: context.metadataText),
                        Text('\$15,000 max', style: context.metadataText),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        key: const Key('save_limit_button'),
                        onPressed: () {
                          notifier.updateMonthlyLimit(card.id, currentLimit);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Monthly limit updated to \$${currentLimit.toStringAsFixed(0)}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primarySage,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(color: colors.borderDark, width: 1.5),
                          ),
                        ),
                        child: Text('Save Limit', style: context.labelMd),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestNewCardDialog(
    BuildContext context,
    CardsNotifier notifier,
  ) {
    final colors = context.pastelColors;
    bool isVirtual = true;
    final nameController = TextEditingController(text: 'Alex Johnson');
    final labelController = TextEditingController(text: 'Marketing Cloud');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: AppTheme.marginMobile,
                right: AppTheme.marginMobile,
                top: AppTheme.marginMobile,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: colors.borderDark, width: 2.0),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.borderDark.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Request Corporate Card',
                        style: context.headlineMd.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Provision a virtual card instantly or order a physical corporate Visa',
                        style: context.bodyMd.copyWith(
                          color: colors.borderDark.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Virtual vs Physical toggle
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              key: const Key('card_type_virtual'),
                              onTap: () => setModalState(() => isVirtual = true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isVirtual ? colors.mint : colors.cardSurfaceAlt,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.borderDark,
                                    width: isVirtual ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.bolt_rounded, color: colors.borderDark),
                                    const SizedBox(height: 4),
                                    Text('Virtual (Instant)', style: context.labelMd),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              key: const Key('card_type_physical'),
                              onTap: () => setModalState(() => isVirtual = false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isVirtual ? colors.peach : colors.cardSurfaceAlt,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.borderDark,
                                    width: !isVirtual ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.credit_card_rounded, color: colors.borderDark),
                                    const SizedBox(height: 4),
                                    Text('Physical Plastic', style: context.labelMd),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card Label
                      Text('Card Purpose / Label', style: context.labelMd),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const Key('new_card_label_input'),
                        controller: labelController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Travel Stipend or Dev Tools',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.borderDark),
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cardholder Name
                      Text('Cardholder Name', style: context.labelMd),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const Key('new_card_name_input'),
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Employee Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.borderDark),
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Provisioning
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          key: const Key('submit_new_card_button'),
                          onPressed: () {
                            notifier.requestNewCard(
                              cardholderName: nameController.text,
                              isVirtual: isVirtual,
                              monthlyLimit: 2500.0,
                              cardLabel: labelController.text,
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'New ${isVirtual ? "Virtual" : "Physical"} Card requested successfully!',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primarySage,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(color: colors.borderDark, width: 1.5),
                            ),
                          ),
                          child: Text('Submit Request', style: context.labelMd),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final state = ref.watch(cardsProvider);
    final notifier = ref.read(cardsProvider.notifier);
    final selectedCard = state.selectedCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Cards'),
        actions: [
          IconButton(
            key: const Key('new_card_header_button'),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Request Card',
            onPressed: () => _showRequestNewCardDialog(context, notifier),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const CardsSkeletonLoader(key: Key('cards_skeleton_loader'))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Cards',
                          style: context.headlineLg.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage active corporate cards',
                          style: context.bodyMd.copyWith(
                            color: colors.borderDark.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      key: const Key('new_card_text_button'),
                      onPressed: () => _showRequestNewCardDialog(context, notifier),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('New'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.primarySage,
                        textStyle: context.labelMd.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Horizontal PageView Card Carousel
              SizedBox(
                height: 215,
                child: PageView.builder(
                  key: const Key('cards_page_view'),
                  controller: _pageController,
                  itemCount: state.cards.length,
                  onPageChanged: notifier.selectCard,
                  itemBuilder: (context, index) {
                    final card = state.cards[index];
                    final isSelected = index == state.selectedCardIndex;
                    return _buildCardItem(colors, card, isSelected);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // 3. Carousel Dots Indicator
              _buildDotsIndicator(colors, state),
              const SizedBox(height: 20),

              // 4. Spend Limit Progress Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                child: _buildSpendLimitBar(colors, selectedCard),
              ),
              const SizedBox(height: 20),

              // 5. Card Management Toggles Bento
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                child: _buildManagementControls(colors, selectedCard, notifier),
              ),
              const SizedBox(height: 24),

              // 6. Recent Activity for Selected Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                child: _buildRecentActivity(colors, state),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual corporate card graphic (Physical or Virtual) matching Stitch styling.
  Widget _buildCardItem(
    AppPastelColors colors,
    CorporateCard card,
    bool isSelected,
  ) {
    // Determine card gradient based on card type
    final gradient = card.isVirtual
        ? const LinearGradient(
            colors: [Color(0xFF206A57), Color(0xFF0F5E4C), Color(0xFF366758)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF0F5E4C), Color(0xFF004536), Color(0xFFC9A227)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.15),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius - 1),
        child: Stack(
          children: [
            // Base Gradient Card
            Container(
              decoration: BoxDecoration(gradient: gradient),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Brand & Contactless / Virtual Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.displayName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (card.isVirtual)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VIRTUAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.contactless_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                    ],
                  ),

                  // Middle Row: EMV Chip Graphic
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black26, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            Container(width: 1, color: Colors.black26),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Bottom Row: Masked PAN, Cardholder, and Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARD NUMBER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '•••• •••• •••• ${card.last4}',
                            key: Key('card_pan_${card.id}'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card.cardholderName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'EXP',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.formattedExpiry,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Frozen Overlay Effect
            if (card.isFrozen)
              Positioned.fill(
                child: Container(
                  key: Key('card_frozen_overlay_${card.id}'),
                  color: Colors.black.withValues(alpha: 0.65),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.mint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.borderDark, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ac_unit_rounded, size: 18, color: colors.borderDark),
                          const SizedBox(width: 8),
                          Text(
                            'CARD FROZEN ❄️',
                            style: TextStyle(
                              color: colors.borderDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Carousel dot indicator.
  Widget _buildDotsIndicator(AppPastelColors colors, CardsState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        state.cards.length,
        (index) {
          final isSelected = index == state.selectedCardIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isSelected ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isSelected ? colors.primarySage : colors.cardSurfaceAlt,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colors.borderDark,
                width: 1.0,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Spend progress meter for the selected card.
  Widget _buildSpendLimitBar(AppPastelColors colors, CorporateCard card) {
    final progress = card.monthlyLimit > 0
        ? (card.currentSpend / card.monthlyLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.borderDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 3),
            blurRadius: 0,
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
                'Monthly Spend Utilization',
                style: context.labelMd.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: context.metadataText.copyWith(
                  fontWeight: FontWeight.w800,
                  color: progress > 0.8 ? Colors.redAccent : colors.borderDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colors.cardSurfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? colors.peach : colors.mint,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${card.currentSpend.toStringAsFixed(2)}',
                style: context.metadataText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.borderDark.withValues(alpha: 0.8),
                ),
              ),
              Text(
                'Limit: \$${card.monthlyLimit.toStringAsFixed(2)}',
                style: context.metadataText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.borderDark.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card management controls bento box: Freeze toggle, View Limits, Request New Card.
  Widget _buildManagementControls(
    AppPastelColors colors,
    CorporateCard card,
    CardsNotifier notifier,
  ) {
    return Column(
      children: [
        // 1. Freeze Card Toggle Tile
        Container(
          decoration: BoxDecoration(
            color: colors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: colors.borderDark, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: card.isFrozen ? colors.peach : colors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.borderDark, width: 1.0),
                ),
                child: Icon(
                  card.isFrozen ? Icons.lock_rounded : Icons.ac_unit_rounded,
                  color: colors.borderDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Freeze Card',
                      style: context.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.isFrozen
                          ? 'Card is temporarily locked'
                          : (card.isVirtual
                              ? 'Pause active subscriptions'
                              : 'Temporarily lock physical card'),
                      style: context.metadataText.copyWith(
                        color: colors.borderDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: const Key('card_freeze_switch'),
                value: card.isFrozen,
                activeTrackColor: colors.primarySage,
                onChanged: (val) {
                  notifier.setFreeze(card.id, val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val
                            ? '${card.displayName} is now frozen'
                            : '${card.displayName} has been unlocked',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Adjust Limit Tile
        InkWell(
          key: const Key('card_limit_tile'),
          onTap: () => _showAdjustLimitDialog(context, card, notifier),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: colors.cardSurface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(color: colors.borderDark, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.skyBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderDark, width: 1.0),
                  ),
                  child: Icon(
                    Icons.speed_rounded,
                    color: colors.borderDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending Limits',
                        style: context.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monthly Limit: \$${card.monthlyLimit.toStringAsFixed(0)}',
                        style: context.metadataText.copyWith(
                          color: colors.borderDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.borderDark.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Request New Card Button Tile
        InkWell(
          key: const Key('request_new_card_button'),
          onTap: () => _showRequestNewCardDialog(context, notifier),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: colors.cardSurface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(color: colors.borderDark, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.lavender,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderDark, width: 1.0),
                  ),
                  child: Icon(
                    Icons.add_card_rounded,
                    color: colors.borderDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request New Card',
                        style: context.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Virtual or physical corporate cards',
                        style: context.metadataText.copyWith(
                          color: colors.borderDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.borderDark.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Recent transactions filtered by currently selected card.
  Widget _buildRecentActivity(AppPastelColors colors, CardsState state) {
    final transactions = state.selectedCardTransactions;
    final card = state.selectedCard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY (${card.last4})',
          style: context.metadataText.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: colors.borderDark.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.cardSurface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(color: colors.borderDark, width: 1.5),
            ),
            child: Center(
              child: Text(
                'No transactions on this card yet',
                style: context.bodyMedium.copyWith(
                  color: colors.borderDark.withValues(alpha: 0.6),
                ),
              ),
            ),
          )
        else
          ...transactions.map((tx) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: colors.cardSurface,
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                border: Border.all(color: colors.borderDark, width: 1.0),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                child: ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.cardSurfaceAlt,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderDark, width: 1.0),
                  ),
                  child: Icon(
                    _iconForName(tx.iconName),
                    size: 18,
                    color: colors.borderDark,
                  ),
                ),
                title: Text(
                  tx.merchant,
                  style: context.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  tx.category,
                  style: context.metadataText.copyWith(
                    color: colors.borderDark.withValues(alpha: 0.7),
                  ),
                ),
                trailing: Text(
                  '-\$${tx.amount.toStringAsFixed(2)}',
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.borderDark,
                  ),
                ),
                onTap: () {
                  context.push('/transaction-detail?id=${tx.id}');
                },
              ),
            ),
          );
          }),
      ],
    );
  }

  IconData _iconForName(String name) {
    switch (name) {
      case 'local_cafe':
        return Icons.coffee_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'code':
        return Icons.code_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }
}
