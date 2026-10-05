import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/models/models.dart';
import 'package:expense_guard/features/expenses/providers/transaction_details_provider.dart';

/// Screen displaying comprehensive transaction details, map snippet,
/// itemized line items, full receipt image with zoom dialog,
/// policy compliance verification badges, and approval status timeline.
/// Based on Stitch Screen ID: 67810d7196af46408b024664185c9ffc ("Pastel Flat").
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    super.key,
    this.transactionId,
    this.heroTag,
  });

  /// The transaction ID passed via path parameter, query parameter, or extra.
  final String? transactionId;

  /// Optional custom Hero tag for receipt flight transitions.
  final String? heroTag;

  static const String defaultScreenId = '67810d7196af46408b024664185c9ffc';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveId = (transactionId != null && transactionId!.isNotEmpty)
        ? transactionId!
        : defaultScreenId;

    final details = ref.watch(transactionDetailsProvider(effectiveId));
    final colors = context.pastelColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: InkWell(
              key: const Key('transaction_detail_back_button'),
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.cardSurface,
                  border: Border.all(
                    color: colors.borderDark,
                    width: AppTheme.borderWidth,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colors.borderDark,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Transaction Detail',
          style: context.headlineMd.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              key: const Key('transaction_detail_share_button'),
              icon: Icon(
                Icons.ios_share_rounded,
                color: colors.borderDark,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Exporting ${details.transaction.merchant} expense summary...',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.marginMobile,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Status Pill
              Center(child: _buildStatusPill(colors, details.transaction.status)),
              const SizedBox(height: 16),

              // 2. Receipt Image Container with Zoom Trigger
              _buildReceiptContainer(context, colors, details),
              const SizedBox(height: 20),

              // 3. Primary Transaction Details Card
              _buildTransactionSummaryCard(context, colors, details),
              const SizedBox(height: 20),

              // 4. Map Snippet (if applicable)
              if (details.mapSnippet != null) ...[
                _buildMapSnippetCard(context, colors, details.mapSnippet!),
                const SizedBox(height: 20),
              ],

              // 5. Itemized Line Items Breakdown
              _buildLineItemsCard(context, colors, details),
              const SizedBox(height: 20),

              // 6. Policy Check Bento Section
              _buildPolicyCheckCard(context, colors, details),
              const SizedBox(height: 20),

              // 7. Approval Status Timeline
              _buildApprovalTimelineCard(context, colors, details),
              const SizedBox(height: 24),

              // 8. Bottom Action Controls
              _buildBottomActions(context, colors, details, ref, effectiveId),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the signature Pastel Flat status pill.
  Widget _buildStatusPill(AppPastelColors colors, TransactionStatus status) {
    Color pillBg;
    Color textColor = colors.borderDark;
    IconData icon;
    String label = status.displayName;

    switch (status) {
      case TransactionStatus.autoCleared:
        pillBg = colors.mint;
        icon = Icons.check_circle_rounded;
        label = 'Auto-cleared';
        break;
      case TransactionStatus.cleared:
        pillBg = colors.mint;
        icon = Icons.verified_rounded;
        label = 'Cleared';
        break;
      case TransactionStatus.reviewing:
        pillBg = colors.peach;
        icon = Icons.schedule_rounded;
        label = 'Reviewing';
        break;
      case TransactionStatus.pending:
        pillBg = colors.peachDim;
        icon = Icons.hourglass_empty_rounded;
        label = 'Pending';
        break;
      case TransactionStatus.flagged:
        pillBg = const Color(0xFFFFDAD6);
        textColor = const Color(0xFF93000A);
        icon = Icons.warning_amber_rounded;
        label = 'Policy Flag';
        break;
    }

    return Container(
      key: const Key('status_pill'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 4:3 receipt thumbnail container with tap-to-zoom capability.
  Widget _buildReceiptContainer(
    BuildContext context,
    AppPastelColors colors,
    TransactionDetails details,
  ) {
    return Hero(
      tag: heroTag ?? 'receipt_hero_${details.transaction.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          key: const Key('receipt_thumbnail_container'),
          decoration: BoxDecoration(
            color: colors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(
              color: colors.borderDark,
              width: AppTheme.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.borderDark.withValues(alpha: 0.10),
                offset: const Offset(3, 4),
                blurRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Receipt Content
                _buildReceiptMediaContent(colors, details),

                // Tap Overlay for entire thumbnail
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showReceiptZoomDialog(context, details),
                    child: const SizedBox.expand(),
                  ),
                ),

                // Zoom In Badge Action (bottom-right)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: InkWell(
                    key: const Key('receipt_zoom_button'),
                    onTap: () => _showReceiptZoomDialog(context, details),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1C1E).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Renders either an image or a high-fidelity stylized receipt paper graphic.
  Widget _buildReceiptMediaContent(
    AppPastelColors colors,
    TransactionDetails details,
  ) {
    final image = details.receiptImageUrl;

    if (image != null && image.isNotEmpty) {
      if (image.startsWith('http://') || image.startsWith('https://')) {
        return Image.network(
          image,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primarySage,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildStylizedReceiptPaper(colors, details);
          },
        );
      } else if (File(image).existsSync()) {
        return Image.file(File(image), fit: BoxFit.cover);
      }
    }

    return _buildStylizedReceiptPaper(colors, details);
  }

  /// Stylized simulated thermal receipt paper design.
  Widget _buildStylizedReceiptPaper(
    AppPastelColors colors,
    TransactionDetails details,
  ) {
    final txn = details.transaction;

    return Container(
      color: const Color(0xFFFAF9F6),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded, size: 32, color: colors.borderDark),
          const SizedBox(height: 6),
          Text(
            txn.merchant.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(txn.timestamp),
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 11,
              color: const Color(0xFF1A1C1E).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '--------------------------------',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: const Color(0xFF1A1C1E).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ITEM COUNT: ${details.lineItems.length}',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              Text(
                'TOTAL: \$${txn.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Displays the interactive zoom dialog supporting pinch-to-zoom and pan.
  void _showReceiptZoomDialog(
    BuildContext context,
    TransactionDetails details,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C1E),
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header with close button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Receipt Inspection',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        key: const Key('receipt_zoom_close_button'),
                        onTap: () => Navigator.of(dialogContext).pop(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),

                // Interactive zoomable container
                SizedBox(
                  height: MediaQuery.of(dialogContext).size.height * 0.55,
                  width: double.infinity,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: details.receiptImageUrl != null &&
                              details.receiptImageUrl!.isNotEmpty
                          ? Image.network(
                              details.receiptImageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) =>
                                  _buildStylizedReceiptPaper(
                                context.pastelColors,
                                details,
                              ),
                            )
                          : _buildStylizedReceiptPaper(
                              context.pastelColors,
                              details,
                            ),
                    ),
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),
                // Footer helper
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.pinch_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pinch or drag to inspect high-resolution details',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the primary transaction details card matching the Stitch layout.
  Widget _buildTransactionSummaryCard(
    BuildContext context,
    AppPastelColors colors,
    TransactionDetails details,
  ) {
    final txn = details.transaction;

    return Container(
      key: const Key('transaction_summary_card'),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Merchant & Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.merchant,
                      style: context.headlineMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(txn.timestamp),
                      style: context.metadataText.copyWith(
                        color: colors.borderDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${txn.amount.toStringAsFixed(2)}',
                    style: context.headlineMd.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    txn.category,
                    style: context.metadataText.copyWith(
                      color: colors.borderDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colors.borderDark.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),

          // Payment Metadata Pills
          Row(
            children: [
              // Card info pill
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.tagBackground,
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    border: Border.all(
                      color: colors.borderDark.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.credit_card_rounded,
                        size: 16,
                        color: colors.borderDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          details.paymentMethod,
                          style: context.metadataText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.borderDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Cardholder pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.tagBackground,
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  border: Border.all(
                    color: colors.borderDark.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: colors.borderDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      details.cardHolder,
                      style: context.metadataText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.borderDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the stylized pastel map snippet card.
  Widget _buildMapSnippetCard(
    BuildContext context,
    AppPastelColors colors,
    MapSnippetData mapSnippet,
  ) {
    return Container(
      key: const Key('map_snippet_card'),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.cardSurfaceAlt,
              border: Border(
                bottom: BorderSide(
                  color: colors.borderDark,
                  width: AppTheme.borderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place_rounded,
                  color: colors.primarySage,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Merchant Location',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.skyBlueDim,
                    borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                    border: Border.all(color: colors.borderDark, width: 1.0),
                  ),
                  child: Text(
                    mapSnippet.city,
                    style: context.metadataText.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stylized Vector Map Preview
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                // Pastel Map Canvas
                CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _PastelMapPainter(colors: colors),
                  child: Container(),
                ),

                // Center Location Pin Badge
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.mint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.borderDark,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.borderDark.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: colors.borderDark,
                          size: 22,
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 3,
                        decoration: BoxDecoration(
                          color: colors.borderDark.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Location Details Footer
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mapSnippet.locationName,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mapSnippet.address,
                  style: context.bodyMd.copyWith(
                    color: colors.borderDark.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the itemized line items breakdown card.
  Widget _buildLineItemsCard(
    BuildContext context,
    AppPastelColors colors,
    TransactionDetails details,
  ) {
    return Container(
      key: const Key('line_items_section'),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.cardSurfaceAlt,
              border: Border(
                bottom: BorderSide(
                  color: colors.borderDark,
                  width: AppTheme.borderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: colors.primarySage,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Itemized Breakdown',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${details.lineItems.length} items',
                  style: context.metadataText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.borderDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Line items list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                for (final item in details.lineItems) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.tagBackground,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colors.borderDark.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: context.metadataText.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.borderDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Description
                        Expanded(
                          child: Text(
                            item.description,
                            style: context.bodyMedium.copyWith(
                              color: colors.borderDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Line Item Amount
                        Text(
                          '\$${item.amount.toStringAsFixed(2)}',
                          style: context.bodyMedium.copyWith(
                            color: colors.borderDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Divider(
                  color: colors.borderDark.withValues(alpha: 0.15),
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Subtotal / Tax / Total
                if (details.subtotal != null) ...[
                  _buildFinancialRow(
                    context,
                    colors,
                    'Subtotal',
                    '\$${details.subtotal!.toStringAsFixed(2)}',
                  ),
                ],
                if (details.tax != null && details.tax! > 0) ...[
                  const SizedBox(height: 4),
                  _buildFinancialRow(
                    context,
                    colors,
                    'Tax',
                    '\$${details.tax!.toStringAsFixed(2)}',
                  ),
                ],
                if (details.tip != null && details.tip! > 0) ...[
                  const SizedBox(height: 4),
                  _buildFinancialRow(
                    context,
                    colors,
                    'Tip',
                    '\$${details.tip!.toStringAsFixed(2)}',
                  ),
                ],
                const SizedBox(height: 8),
                _buildFinancialRow(
                  context,
                  colors,
                  'Total',
                  '\$${details.transaction.amount.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    BuildContext context,
    AppPastelColors colors,
    String label,
    String amount, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? context.titleMedium.copyWith(fontWeight: FontWeight.w800)
              : context.metadataText.copyWith(
                  color: colors.borderDark.withValues(alpha: 0.7),
                ),
        ),
        Text(
          amount,
          style: isBold
              ? context.titleMedium.copyWith(fontWeight: FontWeight.w800)
              : context.metadataText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.borderDark,
                ),
        ),
      ],
    );
  }

  /// Builds the Bento-style Policy Check card with checklist & explanation.
  Widget _buildPolicyCheckCard(
    BuildContext context,
    AppPastelColors colors,
    TransactionDetails details,
  ) {
    return Container(
      key: const Key('policy_check_section'),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.cardSurfaceAlt,
              border: Border(
                bottom: BorderSide(
                  color: colors.borderDark,
                  width: AppTheme.borderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.policy_rounded,
                  color: colors.primarySage,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Policy Check',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Policy Violation Badges (if present)
                if (details.policyViolationBadges.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final badge in details.policyViolationBadges)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDAD6),
                            borderRadius: BorderRadius.circular(
                              AppTheme.chipRadius,
                            ),
                            border: Border.all(
                              color: const Color(0xFF93000A),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: Color(0xFF93000A),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF93000A),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Checklist Items
                for (final check in details.policyChecks) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Indicator Icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: check.isPassed
                                ? colors.mint
                                : const Color(0xFFFFDAD6),
                            border: Border.all(
                              color: colors.borderDark,
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            check.isPassed
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 15,
                            color: check.isPassed
                                ? colors.borderDark
                                : const Color(0xFF93000A),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title & Detail
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                check.title,
                                style: context.bodyMedium.copyWith(
                                  color: colors.borderDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (check.detail != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  check.detail!,
                                  style: context.metadataText.copyWith(
                                    color: colors.borderDark.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Plain language AI explanation container
                if (details.policyExplanation != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: details.policyViolationBadges.isNotEmpty
                          ? const Color(0xFFFFF4EC)
                          : colors.cardSurfaceAlt,
                      borderRadius: BorderRadius.circular(
                        AppTheme.buttonRadius,
                      ),
                      border: Border.all(
                        color: colors.borderDark.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      details.policyExplanation!,
                      style: context.bodyMedium.copyWith(
                        fontSize: 13,
                        color: colors.borderDark.withValues(alpha: 0.85),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the approval status workflow timeline card.
  Widget _buildApprovalTimelineCard(
    BuildContext context,
    AppPastelColors colors,
    TransactionDetails details,
  ) {
    return Container(
      key: const Key('approval_timeline_section'),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: colors.borderDark,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.cardSurfaceAlt,
              border: Border(
                bottom: BorderSide(
                  color: colors.borderDark,
                  width: AppTheme.borderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timeline_rounded,
                  color: colors.primarySage,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Approval Workflow',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Timeline steps list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                for (var i = 0; i < details.timeline.length; i++) ...[
                  _buildTimelineStepRow(
                    context,
                    colors,
                    step: details.timeline[i],
                    isLast: i == details.timeline.length - 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Individual step node in the vertical approval timeline.
  Widget _buildTimelineStepRow(
    BuildContext context,
    AppPastelColors colors, {
    required ApprovalTimelineStep step,
    required bool isLast,
  }) {
    Color nodeColor;
    IconData nodeIcon;
    Color iconColor;

    if (step.isRejected) {
      nodeColor = const Color(0xFFFFDAD6);
      nodeIcon = Icons.priority_high_rounded;
      iconColor = const Color(0xFF93000A);
    } else if (step.isCompleted) {
      nodeColor = colors.mint;
      nodeIcon = Icons.check_rounded;
      iconColor = colors.borderDark;
    } else if (step.isCurrent) {
      nodeColor = colors.peach;
      nodeIcon = Icons.pending_outlined;
      iconColor = colors.borderDark;
    } else {
      nodeColor = colors.tagBackground;
      nodeIcon = Icons.circle_outlined;
      iconColor = colors.borderDark.withValues(alpha: 0.4);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Line & Node
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.borderDark,
                    width: 1.2,
                  ),
                ),
                child: Icon(nodeIcon, size: 15, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: colors.borderDark.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.borderDark,
                        ),
                      ),
                      Text(
                        _formatShortTime(step.timestamp),
                        style: context.metadataText.copyWith(
                          color: colors.borderDark.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: context.metadataText.copyWith(
                      color: colors.borderDark.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Action buttons at the foot of the screen.
  Widget _buildBottomActions(
    BuildContext context,
    AppPastelColors colors,
    TransactionDetails details,
    WidgetRef ref,
    String effectiveId,
  ) {
    final hasViolations = details.policyViolationBadges.isNotEmpty;

    return Column(
      children: [
        if (hasViolations) ...[
          ElevatedButton.icon(
            key: const Key('resolve_violation_button'),
            onPressed: () {
              ref
                  .read(transactionDetailsNotifierProvider(effectiveId).notifier)
                  .markAsCleared();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction submitted for compliance review'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Resolve Policy Flag'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.mint,
              foregroundColor: colors.borderDark,
              elevation: 0,
              side: BorderSide(
                color: colors.borderDark,
                width: AppTheme.borderWidth,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton(
          key: const Key('transaction_detail_dismiss_button'),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.borderDark,
            side: BorderSide(
              color: colors.borderDark,
              width: AppTheme.borderWidth,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Center(child: Text('Done')),
        ),
      ],
    );
  }

  static String _formatTimestamp(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dt.day}, ${dt.year} • ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  static String _formatShortTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

/// Custom painter for the vector-based pastel aesthetic map canvas.
class _PastelMapPainter extends CustomPainter {
  const _PastelMapPainter({required this.colors});

  final AppPastelColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    // Background fill
    final bgPaint = Paint()..color = const Color(0xFFE9F1EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // City blocks
    final blockPaint = Paint()..color = const Color(0xFFDFEAE6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, size.width * 0.4, 45),
        const Radius.circular(6),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 8, size.width * 0.4, 48),
        const Radius.circular(6),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 75, size.width * 0.42, 55),
        const Radius.circular(6),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.56, 70, size.width * 0.38, 60),
        const Radius.circular(6),
      ),
      blockPaint,
    );

    // Main Avenue road
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(-10, size.height * 0.5)
      ..lineTo(size.width + 10, size.height * 0.5);
    canvas.drawPath(path, roadPaint);

    // Cross street
    final crossRoad = Path()
      ..moveTo(size.width * 0.48, -10)
      ..lineTo(size.width * 0.48, size.height + 10);
    canvas.drawPath(crossRoad, roadPaint);

    // Road borders
    final roadBorderPaint = Paint()
      ..color = colors.borderDark.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(-10, size.height * 0.5 - 7),
      Offset(size.width + 10, size.height * 0.5 - 7),
      roadBorderPaint,
    );
    canvas.drawLine(
      Offset(-10, size.height * 0.5 + 7),
      Offset(size.width + 10, size.height * 0.5 + 7),
      roadBorderPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48 - 7, -10),
      Offset(size.width * 0.48 - 7, size.height + 10),
      roadBorderPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48 + 7, -10),
      Offset(size.width * 0.48 + 7, size.height + 10),
      roadBorderPaint,
    );

    // Subtle radar ripple ring around the pin
    final radarPaint = Paint()
      ..color = colors.mint.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.5),
      28,
      radarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PastelMapPainter oldDelegate) => false;
}
