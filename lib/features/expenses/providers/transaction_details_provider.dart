import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/models.dart';
import 'package:expense_guard/features/home/providers/home_provider.dart';

/// Individual compliance rule check for a transaction.
@immutable
class PolicyCheckItem {
  const PolicyCheckItem({
    required this.title,
    required this.isPassed,
    this.detail,
  });

  final String title;
  final bool isPassed;
  final String? detail;

  PolicyCheckItem copyWith({
    String? title,
    bool? isPassed,
    String? detail,
  }) {
    return PolicyCheckItem(
      title: title ?? this.title,
      isPassed: isPassed ?? this.isPassed,
      detail: detail ?? this.detail,
    );
  }
}

/// A stage in the approval workflow timeline.
@immutable
class ApprovalTimelineStep {
  const ApprovalTimelineStep({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isCompleted,
    this.isCurrent = false,
    this.isRejected = false,
  });

  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final bool isRejected;

  ApprovalTimelineStep copyWith({
    String? title,
    String? subtitle,
    DateTime? timestamp,
    bool? isCompleted,
    bool? isCurrent,
    bool? isRejected,
  }) {
    return ApprovalTimelineStep(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
      isRejected: isRejected ?? this.isRejected,
    );
  }
}

/// Geographic context snippet for physical in-store or transit transactions.
@immutable
class MapSnippetData {
  const MapSnippetData({
    required this.locationName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city = 'San Francisco, CA',
  });

  final String locationName;
  final String address;
  final double latitude;
  final double longitude;
  final String city;
}

/// Comprehensive detail aggregate for a single transaction.
@immutable
class TransactionDetails {
  const TransactionDetails({
    required this.transaction,
    this.receiptImageUrl,
    this.mapSnippet,
    this.lineItems = const [],
    this.policyChecks = const [],
    this.policyViolationBadges = const [],
    this.policyExplanation,
    this.timeline = const [],
    this.subtotal,
    this.tax,
    this.tip,
    this.cardHolder = 'Alex Chen',
    this.paymentMethod = 'Corporate Visa •••• 4291',
    this.notes,
  });

  final Transaction transaction;
  final String? receiptImageUrl;
  final MapSnippetData? mapSnippet;
  final List<ExpenseLineItem> lineItems;
  final List<PolicyCheckItem> policyChecks;
  final List<String> policyViolationBadges;
  final String? policyExplanation;
  final List<ApprovalTimelineStep> timeline;
  final double? subtotal;
  final double? tax;
  final double? tip;
  final String cardHolder;
  final String paymentMethod;
  final String? notes;

  TransactionDetails copyWith({
    Transaction? transaction,
    String? receiptImageUrl,
    MapSnippetData? mapSnippet,
    List<ExpenseLineItem>? lineItems,
    List<PolicyCheckItem>? policyChecks,
    List<String>? policyViolationBadges,
    String? policyExplanation,
    List<ApprovalTimelineStep>? timeline,
    double? subtotal,
    double? tax,
    double? tip,
    String? cardHolder,
    String? paymentMethod,
    String? notes,
  }) {
    return TransactionDetails(
      transaction: transaction ?? this.transaction,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      mapSnippet: mapSnippet ?? this.mapSnippet,
      lineItems: lineItems ?? this.lineItems,
      policyChecks: policyChecks ?? this.policyChecks,
      policyViolationBadges:
          policyViolationBadges ?? this.policyViolationBadges,
      policyExplanation: policyExplanation ?? this.policyExplanation,
      timeline: timeline ?? this.timeline,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      tip: tip ?? this.tip,
      cardHolder: cardHolder ?? this.cardHolder,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}

/// State notifier managing transaction detail state by ID.
class TransactionDetailsNotifier extends Notifier<TransactionDetails> {
  TransactionDetailsNotifier(this.id);

  final String id;

  @override
  TransactionDetails build() {
    return _resolveDetails(id);
  }

  TransactionDetails _resolveDetails(String id) {
    final now = DateTime.now();

    // Check if matching transaction exists in HomeState
    final homeTransactions = ref.read(homeStateProvider).recentTransactions;
    final matchedTxn = homeTransactions.cast<Transaction?>().firstWhere(
          (t) => t?.id.toLowerCase() == id.toLowerCase(),
          orElse: () => null,
        );

    // 1. Blue Bottle Coffee (Default Stitch screen 67810d7196af46408b024664185c9ffc)
    if (id.isEmpty ||
        id == '67810d7196af46408b024664185c9ffc' ||
        id.toLowerCase().contains('blue-bottle') ||
        matchedTxn == null && !id.startsWith('txn-')) {
      final baseTxn = matchedTxn ??
          Transaction(
            id: id.isNotEmpty ? id : '67810d7196af46408b024664185c9ffc',
            merchant: 'Blue Bottle Coffee',
            amount: 12.50,
            currency: 'USD',
            category: 'Food & Beverage',
            timestamp: DateTime(2023, 10, 24, 8, 42),
            status: TransactionStatus.autoCleared,
            cardLast4: '4291',
            iconName: 'local_cafe',
            receiptAttached: true,
          );

      return TransactionDetails(
        transaction: baseTxn,
        receiptImageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDYiZ08gT4bO5CeWtWi20LqBoJMZ9rvS1MBwdTug6g-FPIQxayXtA3daOBLDNeOMOxzkte6-9mwwn1w6bnC5nPJRsl1iun-Htsb7CTDj4qPXcFwjiXE5v_tgEc2bAYzaDH8MrH5dhmzM__hILQA8pGGg5Sc74n4CRMKlLNlo30cTwyJubqVIpNwXEXehAqBZ1rNDh1lphuoCAq_Q5SkPVXCM3PnGYAxl_Fco-c43B4HTXUjaMXJDceU',
        mapSnippet: const MapSnippetData(
          locationName: 'Blue Bottle Coffee • Hayes Valley',
          address: '315 Linden St, San Francisco, CA 94102',
          latitude: 37.7763,
          longitude: -122.4233,
        ),
        lineItems: const [
          ExpenseLineItem(
            description: 'Single Origin Espresso (Hayes Valley)',
            amount: 4.50,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Oat Milk Gibraltar',
            amount: 5.00,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Organic Morning Croissant',
            amount: 3.00,
            quantity: 1,
          ),
        ],
        subtotal: 12.50,
        tax: 0.00,
        tip: 0.00,
        policyChecks: const [
          PolicyCheckItem(
            title: 'Receipt detected',
            isPassed: true,
            detail: 'High-confidence OCR match verified with terminal timestamp.',
          ),
          PolicyCheckItem(
            title: 'Under \$50 threshold',
            isPassed: true,
            detail: 'Amount (\$12.50) is well under the \$50 per-meal auto-approval limit.',
          ),
          PolicyCheckItem(
            title: 'Approved vendor',
            isPassed: true,
            detail: 'Blue Bottle Coffee is a verified merchant category.',
          ),
        ],
        policyViolationBadges: const [],
        policyExplanation:
            "Everything looks good. This transaction matches your team's travel policy and has been cleared automatically.",
        timeline: [
          ApprovalTimelineStep(
            title: 'Card Swiped',
            subtitle: 'Blue Bottle POS Terminal • Tap to Pay',
            timestamp: DateTime(2023, 10, 24, 8, 42),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Receipt Captured',
            subtitle: 'Itemized receipt matched via smart camera',
            timestamp: DateTime(2023, 10, 24, 8, 43),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Policy Evaluated',
            subtitle: 'Automated policy rule engine passed 3/3 checks',
            timestamp: DateTime(2023, 10, 24, 8, 43),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Auto-cleared',
            subtitle: 'Expense cleared automatically without manager intervention',
            timestamp: DateTime(2023, 10, 24, 8, 44),
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      );
    }

    // 2. txn-101: Starbucks
    if (id == 'txn-101' || matchedTxn?.merchant == 'Starbucks') {
      final baseTxn = matchedTxn ??
          Transaction(
            id: 'txn-101',
            merchant: 'Starbucks',
            amount: 6.75,
            currency: 'USD',
            category: 'Meals & Dining',
            timestamp: now.subtract(const Duration(hours: 2)),
            status: TransactionStatus.cleared,
            cardLast4: '4291',
            iconName: 'local_cafe',
            receiptAttached: true,
          );

      return TransactionDetails(
        transaction: baseTxn,
        receiptImageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDYiZ08gT4bO5CeWtWi20LqBoJMZ9rvS1MBwdTug6g-FPIQxayXtA3daOBLDNeOMOxzkte6-9mwwn1w6bnC5nPJRsl1iun-Htsb7CTDj4qPXcFwjiXE5v_tgEc2bAYzaDH8MrH5dhmzM__hILQA8pGGg5Sc74n4CRMKlLNlo30cTwyJubqVIpNwXEXehAqBZ1rNDh1lphuoCAq_Q5SkPVXCM3PnGYAxl_Fco-c43B4HTXUjaMXJDceU',
        mapSnippet: const MapSnippetData(
          locationName: 'Starbucks Coffee',
          address: '201 3rd St, San Francisco, CA 94103',
          latitude: 37.7858,
          longitude: -122.4008,
        ),
        lineItems: const [
          ExpenseLineItem(
            description: 'Grande Iced Brown Sugar Oatmilk',
            amount: 5.75,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Espresso Extra Shot',
            amount: 1.00,
            quantity: 1,
          ),
        ],
        subtotal: 6.75,
        policyChecks: const [
          PolicyCheckItem(title: 'Receipt detected', isPassed: true),
          PolicyCheckItem(title: 'Under \$50 threshold', isPassed: true),
          PolicyCheckItem(title: 'Approved vendor', isPassed: true),
        ],
        policyViolationBadges: const [],
        policyExplanation:
            'Standard meal & beverage expense within allowance. Cleared automatically.',
        timeline: [
          ApprovalTimelineStep(
            title: 'Card Swiped',
            subtitle: 'Starbucks POS #2',
            timestamp: now.subtract(const Duration(hours: 2)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Receipt Matched',
            subtitle: 'Digital receipt parsed via Card Network',
            timestamp: now.subtract(const Duration(hours: 2)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Cleared',
            subtitle: 'Directly settled to corporate card ledger',
            timestamp: now.subtract(const Duration(hours: 1, minutes: 58)),
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      );
    }

    // 3. txn-102: Uber Ride
    if (id == 'txn-102' || matchedTxn?.merchant == 'Uber Ride') {
      final baseTxn = matchedTxn ??
          Transaction(
            id: 'txn-102',
            merchant: 'Uber Ride',
            amount: 24.50,
            currency: 'USD',
            category: 'Transportation',
            timestamp: now.subtract(const Duration(days: 1)),
            status: TransactionStatus.reviewing,
            cardLast4: '4291',
            iconName: 'directions_car',
            receiptAttached: true,
          );

      return TransactionDetails(
        transaction: baseTxn,
        receiptImageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDYiZ08gT4bO5CeWtWi20LqBoJMZ9rvS1MBwdTug6g-FPIQxayXtA3daOBLDNeOMOxzkte6-9mwwn1w6bnC5nPJRsl1iun-Htsb7CTDj4qPXcFwjiXE5v_tgEc2bAYzaDH8MrH5dhmzM__hILQA8pGGg5Sc74n4CRMKlLNlo30cTwyJubqVIpNwXEXehAqBZ1rNDh1lphuoCAq_Q5SkPVXCM3PnGYAxl_Fco-c43B4HTXUjaMXJDceU',
        mapSnippet: const MapSnippetData(
          locationName: 'SFO Airport to Financial District',
          address: 'Terminal 2 → 555 California St, San Francisco, CA',
          latitude: 37.6213,
          longitude: -122.3790,
        ),
        lineItems: const [
          ExpenseLineItem(
            description: 'UberX Trip Fare',
            amount: 19.50,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Airport Access Surcharge',
            amount: 3.00,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Local Transit Tax',
            amount: 2.00,
            quantity: 1,
          ),
        ],
        subtotal: 24.50,
        policyChecks: const [
          PolicyCheckItem(title: 'Receipt detected', isPassed: true),
          PolicyCheckItem(title: 'Approved ground transport', isPassed: true),
          PolicyCheckItem(
            title: 'Business hours travel',
            isPassed: true,
            detail: 'Within business conference travel window.',
          ),
        ],
        policyViolationBadges: const [],
        policyExplanation:
            'Ground transportation receipt uploaded. Scheduled for manager verification batch.',
        timeline: [
          ApprovalTimelineStep(
            title: 'Ride Completed',
            subtitle: 'Uber trip finalized',
            timestamp: now.subtract(const Duration(days: 1)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'E-Receipt Linked',
            subtitle: 'Auto-synced via Uber for Business',
            timestamp: now.subtract(const Duration(days: 1)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Manager Review Pending',
            subtitle: 'Assigned to Finance approval queue',
            timestamp: now.subtract(const Duration(hours: 20)),
            isCompleted: false,
            isCurrent: true,
          ),
        ],
      );
    }

    // 4. txn-103: AWS Cloud Services
    if (id == 'txn-103' || matchedTxn?.merchant == 'AWS Cloud Services') {
      final baseTxn = matchedTxn ??
          Transaction(
            id: 'txn-103',
            merchant: 'AWS Cloud Services',
            amount: 124.50,
            currency: 'USD',
            category: 'Software & Cloud',
            timestamp: now.subtract(const Duration(days: 3)),
            status: TransactionStatus.autoCleared,
            cardLast4: '8812',
            iconName: 'cloud',
            receiptAttached: true,
          );

      return TransactionDetails(
        transaction: baseTxn,
        receiptImageUrl: null,
        mapSnippet: null, // Online SaaS vendor (no physical map)
        lineItems: const [
          ExpenseLineItem(
            description: 'Amazon Elastic Compute Cloud (EC2)',
            amount: 85.00,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Amazon Simple Storage Service (S3)',
            amount: 25.50,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Data Transfer Out (US-West-1)',
            amount: 14.00,
            quantity: 1,
          ),
        ],
        subtotal: 124.50,
        policyChecks: const [
          PolicyCheckItem(title: 'Pre-approved cloud infrastructure', isPassed: true),
          PolicyCheckItem(title: 'Recurring monthly vendor', isPassed: true),
          PolicyCheckItem(title: 'Itemized tax invoice attached', isPassed: true),
        ],
        policyViolationBadges: const [],
        policyExplanation:
            'Recurring engineering infrastructure subscription verified against team budget.',
        timeline: [
          ApprovalTimelineStep(
            title: 'Automated Invoice Received',
            subtitle: 'AWS Billing Portal API sync',
            timestamp: now.subtract(const Duration(days: 3)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Budget Allocation Matched',
            subtitle: 'Charged to Eng-Core cost center',
            timestamp: now.subtract(const Duration(days: 3)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Auto-cleared',
            subtitle: 'Auto-settled via virtual corporate card',
            timestamp: now.subtract(const Duration(days: 3)),
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      );
    }

    // 5. txn-104: Delta Air Lines
    if (id == 'txn-104' || matchedTxn?.merchant == 'Delta Air Lines') {
      final baseTxn = matchedTxn ??
          Transaction(
            id: 'txn-104',
            merchant: 'Delta Air Lines',
            amount: 450.00,
            currency: 'USD',
            category: 'Travel & Lodging',
            timestamp: now.subtract(const Duration(days: 5)),
            status: TransactionStatus.reviewing,
            cardLast4: '4291',
            iconName: 'flight',
            receiptAttached: true,
          );

      return TransactionDetails(
        transaction: baseTxn,
        mapSnippet: const MapSnippetData(
          locationName: 'SFO International Airport',
          address: 'Delta Air Lines Terminal 2, San Francisco, CA',
          latitude: 37.6213,
          longitude: -122.3790,
        ),
        lineItems: const [
          ExpenseLineItem(
            description: 'Main Cabin Flight Ticket (SFO → JFK)',
            amount: 410.00,
            quantity: 1,
          ),
          ExpenseLineItem(
            description: 'Standard Checked Bag',
            amount: 40.00,
            quantity: 1,
          ),
        ],
        subtotal: 450.00,
        policyChecks: const [
          PolicyCheckItem(title: 'Receipt detected', isPassed: true),
          PolicyCheckItem(title: '14-day advance booking window', isPassed: true),
          PolicyCheckItem(
            title: 'Under \$300 auto-approval threshold',
            isPassed: false,
            detail: 'Amount (\$450.00) exceeds single-transaction auto-clear ceiling.',
          ),
        ],
        policyViolationBadges: const ['Exceeds \$300 Ceiling'],
        policyExplanation:
            'Flight expense exceeds the \$300 automated approval threshold. Escalated to Manager review.',
        timeline: [
          ApprovalTimelineStep(
            title: 'Booking Confirmed',
            subtitle: 'Delta Confirmation #DL-9418A',
            timestamp: now.subtract(const Duration(days: 5)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Policy Exception Logged',
            subtitle: 'Threshold violation triggered secondary review rule',
            timestamp: now.subtract(const Duration(days: 5)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Manager Approval Pending',
            subtitle: 'Awaiting sign-off by VP of Engineering',
            timestamp: now.subtract(const Duration(days: 4)),
            isCompleted: false,
            isCurrent: true,
          ),
        ],
      );
    }

    // 6. txn-105: Apple Store
    if (id == 'txn-105' || matchedTxn?.merchant == 'Apple Store') {
      final baseTxn = matchedTxn ??
          Transaction(
            id: 'txn-105',
            merchant: 'Apple Store',
            amount: 129.00,
            currency: 'USD',
            category: 'Hardware & Tools',
            timestamp: now.subtract(const Duration(days: 7)),
            status: TransactionStatus.flagged,
            cardLast4: '4291',
            iconName: 'laptop_mac',
            receiptAttached: false,
          );

      return TransactionDetails(
        transaction: baseTxn,
        mapSnippet: const MapSnippetData(
          locationName: 'Apple Union Square',
          address: '300 Post St, San Francisco, CA 94108',
          latitude: 37.7887,
          longitude: -122.4075,
        ),
        lineItems: const [
          ExpenseLineItem(
            description: 'Magic Keyboard with Touch ID',
            amount: 129.00,
            quantity: 1,
          ),
        ],
        subtotal: 129.00,
        policyChecks: const [
          PolicyCheckItem(
            title: 'Receipt detected',
            isPassed: false,
            detail: 'Missing itemized receipt photo or PDF invoice.',
          ),
          PolicyCheckItem(
            title: 'IT Hardware Pre-approval',
            isPassed: false,
            detail: 'Peripheral equipment requires ticket approval ID.',
          ),
          PolicyCheckItem(title: 'Approved hardware vendor', isPassed: true),
        ],
        policyViolationBadges: const ['Missing Receipt', 'Pre-approval Required'],
        policyExplanation:
            'Hardware purchases over \$100 require an itemized receipt and an approved IT requisition ticket.',
        timeline: [
          ApprovalTimelineStep(
            title: 'In-Store Charge',
            subtitle: 'Apple Union Square Terminal',
            timestamp: now.subtract(const Duration(days: 7)),
            isCompleted: true,
          ),
          ApprovalTimelineStep(
            title: 'Policy Flagged',
            subtitle: 'Missing itemized receipt and IT requisition ticket',
            timestamp: now.subtract(const Duration(days: 7)),
            isCompleted: true,
            isRejected: true,
          ),
          ApprovalTimelineStep(
            title: 'Action Required',
            subtitle: 'Please upload tax receipt to resolve audit flag',
            timestamp: now.subtract(const Duration(days: 6)),
            isCompleted: false,
            isCurrent: true,
          ),
        ],
      );
    }

    // Generic fallback for any arbitrary ID
    final genericTxn = matchedTxn ??
        Transaction(
          id: id,
          merchant: 'Merchant #${id.substring(0, id.length > 6 ? 6 : id.length).toUpperCase()}',
          amount: 28.75,
          currency: 'USD',
          category: 'General Business',
          timestamp: now.subtract(const Duration(days: 2)),
          status: TransactionStatus.cleared,
          cardLast4: '4291',
          iconName: 'receipt',
          receiptAttached: true,
        );

    return TransactionDetails(
      transaction: genericTxn,
      receiptImageUrl: null,
      lineItems: [
        ExpenseLineItem(
          description: '${genericTxn.merchant} Item A',
          amount: genericTxn.amount,
          quantity: 1,
        ),
      ],
      subtotal: genericTxn.amount,
      policyChecks: const [
        PolicyCheckItem(title: 'Receipt detected', isPassed: true),
        PolicyCheckItem(title: 'Under \$50 threshold', isPassed: true),
        PolicyCheckItem(title: 'Approved vendor category', isPassed: true),
      ],
      policyViolationBadges: const [],
      policyExplanation:
          'This transaction complies with general expense guidelines and has cleared.',
      timeline: [
        ApprovalTimelineStep(
          title: 'Transaction Authorized',
          subtitle: 'Point of sale verification',
          timestamp: genericTxn.timestamp,
          isCompleted: true,
        ),
        ApprovalTimelineStep(
          title: 'Settled',
          subtitle: 'Reconciled with corporate ledger',
          timestamp: genericTxn.timestamp.add(const Duration(minutes: 5)),
          isCompleted: true,
          isCurrent: true,
        ),
      ],
    );
  }

  /// Attach a receipt image to the transaction.
  void attachReceipt(String imagePath) {
    state = state.copyWith(
      receiptImageUrl: imagePath,
      transaction: state.transaction.copyWith(receiptAttached: true),
    );
  }

  /// Re-evaluate policy and resolve violations.
  void markAsCleared() {
    state = state.copyWith(
      transaction:
          state.transaction.copyWith(status: TransactionStatus.autoCleared),
      policyViolationBadges: const [],
      policyExplanation: 'Manually cleared by user review.',
    );
  }
}

/// Provider exposing the reactive TransactionDetailsNotifier by ID.
final transactionDetailsNotifierProvider = NotifierProvider.family<
    TransactionDetailsNotifier, TransactionDetails, String>(
  (id) => TransactionDetailsNotifier(id),
);

/// Provider exposing the read-only or watched TransactionDetails by ID.
final transactionDetailsProvider =
    Provider.family<TransactionDetails, String>((ref, id) {
  return ref.watch(transactionDetailsNotifierProvider(id));
});
