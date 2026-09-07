import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/features/approvals/models/approval_item.dart';

/// Filter selection for the Approvals Queue view.
enum ApprovalsFilter {
  all,
  highRisk,
  standard;

  String get label {
    switch (this) {
      case ApprovalsFilter.all:
        return 'All';
      case ApprovalsFilter.highRisk:
        return 'High Risk';
      case ApprovalsFilter.standard:
        return 'Standard';
    }
  }
}

/// Immutable state container for the Approvals Queue.
@immutable
class ApprovalsState {
  const ApprovalsState({
    required this.items,
    this.filter = ApprovalsFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
  });

  final List<ApprovalItem> items;
  final ApprovalsFilter filter;
  final String searchQuery;
  final bool isLoading;

  /// All items currently pending approval.
  List<ApprovalItem> get pendingItems =>
      items.where((i) => i.status == ApprovalStatus.pending).toList();

  /// Pending items classified as High Risk.
  List<ApprovalItem> get highRiskPending =>
      pendingItems.where((i) => i.isHighRisk).toList();

  /// Pending items classified as Standard Routine.
  List<ApprovalItem> get standardPending =>
      pendingItems.where((i) => !i.isHighRisk).toList();

  /// Items filtered by active tab filter and search query.
  List<ApprovalItem> get filteredPendingItems {
    var list = pendingItems;

    switch (filter) {
      case ApprovalsFilter.highRisk:
        list = list.where((i) => i.isHighRisk).toList();
        break;
      case ApprovalsFilter.standard:
        list = list.where((i) => !i.isHighRisk).toList();
        break;
      case ApprovalsFilter.all:
        break;
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list
          .where((i) =>
              i.employeeName.toLowerCase().contains(q) ||
              i.merchant.toLowerCase().contains(q) ||
              i.category.toLowerCase().contains(q) ||
              (i.policyWarning != null &&
                  i.policyWarning!.toLowerCase().contains(q)))
          .toList();
    }

    return list;
  }

  int get pendingCount => pendingItems.length;
  int get highRiskCount => highRiskPending.length;
  int get standardCount => standardPending.length;

  double get totalPendingAmount =>
      pendingItems.fold(0.0, (sum, item) => sum + item.amount);

  ApprovalsState copyWith({
    List<ApprovalItem>? items,
    ApprovalsFilter? filter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return ApprovalsState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// State notifier managing team expense approvals, swipe-to-approve, and swipe-to-reject.
class ApprovalsNotifier extends Notifier<ApprovalsState> {
  @override
  ApprovalsState build() {
    return ApprovalsState(items: _buildInitialItems());
  }

  static List<ApprovalItem> _buildInitialItems() {
    final now = DateTime.now();

    return [
      // 1. Alex Johnson (From Stitch Screen 0e59c7e30fdf4daf8159c06f687d9ef6)
      ApprovalItem(
        id: 'appr-01',
        transactionId: 'txn-104',
        employeeName: 'Alex Johnson',
        employeeRole: 'Account Executive',
        employeeAvatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBeFThWhTsfP58Oz6PAWb-YZHcjoJB_isnzVr-xjVJAHoQ0YhtgNOfJEGOo5tlZMrxTXdenp3Kkrh_fpnSHqat-AHWkb2v6AqWYuDAUrq1ed6T48FA78ZP3X7lYixFaLgJDViRSf4YHy_1Ww262J-7Up_pPs3J1DjgbBWmaC9zXV63h1O1y_iOCm61dNO0mq_LD_gI5py5vQgA9668i_14ZDOcebvRFV268gvIf_q70val17G9HPzQ5',
        merchant: 'Delta Airlines',
        amount: 840.00,
        category: 'Travel & Lodging',
        date: now.subtract(const Duration(days: 1)),
        riskLevel: ApprovalRiskLevel.highRisk,
        fraudRiskScore: 85,
        policyWarning: 'Exceeds airfare budget by 24%',
        userNote: 'Last minute flight change due to client meeting schedule shift.',
        hasReceipt: true,
        violationTags: const ['Policy Violation', 'Budget Exceeded'],
        iconName: 'flight',
      ),

      // 2. Jamie Smith (From Stitch Screen 0e59c7e30fdf4daf8159c06f687d9ef6)
      ApprovalItem(
        id: 'appr-02',
        transactionId: 'txn-101',
        employeeName: 'Jamie Smith',
        employeeRole: 'Senior Marketing Director',
        merchant: "Ruth's Chris",
        amount: 420.50,
        category: 'Meals & Dining',
        date: now.subtract(const Duration(days: 2)),
        riskLevel: ApprovalRiskLevel.highRisk,
        fraudRiskScore: 74,
        policyWarning: 'Meal exceeds \$150 per-person limit',
        userNote: 'Client dinner with executive team.',
        hasReceipt: true,
        violationTags: const ['Unusually High', 'Executive Dinner'],
        iconName: 'restaurant',
      ),

      // 3. Sarah Jenkins (From Stitch Dark Screen d96c040e831d407685a8cbc4f5841e20)
      ApprovalItem(
        id: 'appr-03',
        transactionId: 'txn-104',
        employeeName: 'Sarah Jenkins',
        employeeRole: 'Infrastructure Lead',
        employeeAvatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD8lDOJingvro1HSmkgyQGUx5I57jyFUKw0SUVuAfbpIDN9LaqhpGgQjr5NTYrVP-khK1PebA__8yy2OaZZN2OyIFgazZRcDizO8IAstAY6c85Q7pj0V0vECAqx64wafGzPB-Kz744Piy0dJhLmAr10Qu5u7bNvY3nU5hXkpxR6JdT_rWSs66uGoOMhFXc2dI-auM93aROsMGf1KF6ZHVZ6oIRZHS7ofBEBaTyKTxlUzSkb4cU6XD02',
        merchant: 'Delta Airlines',
        amount: 1245.00,
        category: 'Travel & Lodging',
        date: now.subtract(const Duration(days: 2)),
        riskLevel: ApprovalRiskLevel.highRisk,
        fraudRiskScore: 92,
        policyWarning: 'Exceeds single-transaction ceiling threshold',
        userNote: 'Emergency flight booking for critical customer datacenter deployment.',
        hasReceipt: true,
        violationTags: const ['Out of Policy', 'Exceeds Ceiling'],
        iconName: 'flight',
      ),

      // 4. David Kim (From Stitch Dark Screen d96c040e831d407685a8cbc4f5841e20)
      ApprovalItem(
        id: 'appr-04',
        transactionId: 'txn-102',
        employeeName: 'David Kim',
        employeeRole: 'Staff Frontend Engineer',
        merchant: 'Marriott Downtown',
        amount: 850.00,
        category: 'Travel & Lodging',
        date: now.subtract(const Duration(days: 3)),
        riskLevel: ApprovalRiskLevel.standard,
        fraudRiskScore: 18,
        policyWarning: null,
        userNote: 'Annual engineering technical conference lodging.',
        hasReceipt: true,
        violationTags: const ['Standard Routine', 'Pre-authorized'],
        iconName: 'hotel',
      ),

      // 5. Elena Rodriguez (From Stitch Dark Screen d96c040e831d407685a8cbc4f5841e20)
      ApprovalItem(
        id: 'appr-05',
        transactionId: 'txn-101',
        employeeName: 'Elena Rodriguez',
        employeeRole: 'Product Operations Manager',
        merchant: 'Client Dinner Bistro',
        amount: 245.50,
        category: 'Meals & Dining',
        date: now.subtract(const Duration(days: 4)),
        riskLevel: ApprovalRiskLevel.standard,
        fraudRiskScore: 12,
        policyWarning: null,
        userNote: 'Quarterly sync dinner with beta client team.',
        hasReceipt: true,
        violationTags: const ['Standard Routine'],
        iconName: 'restaurant',
      ),

      // 6. Marcus Vance (Linked to Apple Store txn-105 policy audit flag)
      ApprovalItem(
        id: 'appr-06',
        transactionId: 'txn-105',
        employeeName: 'Marcus Vance',
        employeeRole: 'Senior iOS Engineer',
        merchant: 'Apple Store',
        amount: 129.00,
        category: 'Hardware & Tools',
        date: now.subtract(const Duration(days: 7)),
        riskLevel: ApprovalRiskLevel.highRisk,
        fraudRiskScore: 78,
        policyWarning: 'Missing itemized receipt photo & IT requisition ticket',
        userNote: 'Replacement keyboard for remote workstation setup.',
        hasReceipt: false,
        violationTags: const ['Missing Receipt', 'IT Pre-approval Required'],
        iconName: 'laptop_mac',
      ),
    ];
  }

  /// Approve an expense item (triggered via swipe right or button tap).
  void approve(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(status: ApprovalStatus.approved);
        }
        return item;
      }).toList(),
    );
  }

  /// Reject/Flag an expense item (triggered via swipe left or button tap).
  void reject(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(status: ApprovalStatus.rejected);
        }
        return item;
      }).toList(),
    );
  }

  /// Flag an expense item for compliance audit.
  void flag(String id) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(status: ApprovalStatus.flagged);
        }
        return item;
      }).toList(),
    );
  }

  /// Restore an expense item's prior status (e.g. on SnackBar Undo).
  void undo(String id, [ApprovalStatus previousStatus = ApprovalStatus.pending]) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(status: previousStatus);
        }
        return item;
      }).toList(),
    );
  }

  /// Update the active category filter (All, High Risk, Standard).
  void setFilter(ApprovalsFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Search by employee, merchant, or policy rule.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Reset approvals state back to default mock items.
  void reset() {
    state = ApprovalsState(items: _buildInitialItems());
  }
}

/// Global provider exposing Approvals Queue state and actions.
final approvalsProvider =
    NotifierProvider<ApprovalsNotifier, ApprovalsState>(ApprovalsNotifier.new);
