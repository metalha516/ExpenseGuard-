import 'package:expense_guard/models/expense.dart';

/// Repository handling expense retrieval, creation, updates, and approval workflows.
class ExpensesRepository {
  ExpensesRepository({List<Expense>? initialData})
      : _expenses = initialData ?? _buildDefaultExpenses();

  final List<Expense> _expenses;

  /// Fetch all expenses with optional filtering.
  Future<List<Expense>> getExpenses({
    String? category,
    ExpenseStatus? status,
    String? searchQuery,
  }) async {
    // Simulate real-world network latency (microtask/delay)
    await Future<void>.delayed(const Duration(milliseconds: 10));

    return _expenses.where((expense) {
      if (category != null &&
          expense.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (status != null && expense.status != status) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchMerchant = expense.merchant.toLowerCase().contains(query);
        final matchCategory = expense.category.toLowerCase().contains(query);
        final matchNote = expense.notes?.toLowerCase().contains(query) ?? false;
        if (!matchMerchant && !matchCategory && !matchNote) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Fetch single expense by ID.
  Future<Expense?> getExpenseById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new expense.
  Future<Expense> createExpense(Expense expense) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    _expenses.insert(0, expense);
    return expense;
  }

  /// Update an existing expense.
  Future<Expense> updateExpense(Expense expense) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      return expense;
    }
    throw StateError('Expense with id ${expense.id} not found.');
  }

  /// Delete an expense by ID.
  Future<bool> deleteExpense(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final count = _expenses.length;
    _expenses.removeWhere((e) => e.id == id);
    return _expenses.length < count;
  }

  /// Approve an expense.
  Future<Expense> approveExpense(String id) async {
    final expense = await getExpenseById(id);
    if (expense == null) {
      throw StateError('Expense not found.');
    }
    final updated = expense.copyWith(
      status: ExpenseStatus.approved,
      policyCompliant: true,
    );
    return updateExpense(updated);
  }

  /// Reject an expense with a reason.
  Future<Expense> rejectExpense(String id, {String? reason}) async {
    final expense = await getExpenseById(id);
    if (expense == null) {
      throw StateError('Expense not found.');
    }
    final updated = expense.copyWith(
      status: ExpenseStatus.rejected,
      policyNote: reason ?? 'Rejected by finance audit team.',
    );
    return updateExpense(updated);
  }

  /// Populate robust real-world corporate expense scenarios (Delta, AWS, Uber, Apple).
  static List<Expense> _buildDefaultExpenses() {
    final now = DateTime.now();

    return [
      // 1. Delta Airlines: Executive Travel
      Expense(
        id: 'exp-101',
        merchant: 'Delta Air Lines',
        amount: 845.00,
        currency: 'USD',
        category: 'Travel',
        date: DateTime(now.year, now.month, now.day - 1, 14, 20),
        status: ExpenseStatus.approved,
        policyCompliant: true,
        notes: 'Round-trip flight to NY HQ for quarterly engineering summit.',
        cardId: 'card-01',
        receiptUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
        lineItems: const [
          ExpenseLineItem(
            description: 'Delta Main Cabin Comfort+ (JFK -> SFO)',
            amount: 795.00,
          ),
          ExpenseLineItem(
            description: 'Standard Checked Bag Allowance',
            amount: 50.00,
          ),
        ],
      ),

      // 2. Amazon Web Services: Cloud Infrastructure
      Expense(
        id: 'exp-102',
        merchant: 'Amazon Web Services',
        amount: 430.00,
        currency: 'USD',
        category: 'Software',
        date: DateTime(now.year, now.month, now.day - 2, 9, 15),
        status: ExpenseStatus.pending,
        policyCompliant: true,
        notes: 'Production EC2 and Aurora Serverless cluster usage.',
        cardId: 'card-02',
        receiptUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71',
        lineItems: const [
          ExpenseLineItem(
            description: 'AWS us-east-1 Compute Instances',
            amount: 320.00,
          ),
          ExpenseLineItem(
            description: 'Data Transfer & Egress Bandwidth',
            amount: 110.00,
          ),
        ],
      ),

      // 3. Uber Technologies: Corporate Ground Transit
      Expense(
        id: 'exp-103',
        merchant: 'Uber Technologies',
        amount: 54.20,
        currency: 'USD',
        category: 'Transportation',
        date: DateTime(now.year, now.month, now.day - 3, 20, 45),
        status: ExpenseStatus.approved,
        policyCompliant: true,
        notes: 'Airport ground transit from JFK to Manhattan hotel.',
        cardId: 'card-01',
        lineItems: const [
          ExpenseLineItem(
            description: 'Uber Comfort Fare',
            amount: 46.50,
          ),
          ExpenseLineItem(
            description: 'Tolls & Airport Access Surcharge',
            amount: 7.70,
          ),
        ],
      ),

      // 4. Apple Store: Hardware Adapter
      Expense(
        id: 'exp-104',
        merchant: 'Apple Store',
        amount: 89.00,
        currency: 'USD',
        category: 'Equipment',
        date: DateTime(now.year, now.month, now.day - 4, 16, 30),
        status: ExpenseStatus.pending,
        policyCompliant: false,
        policyNote: 'Hardware purchases above \$75 require pre-approved purchase order.',
        notes: 'Replacement 96W USB-C Power Adapter for work laptop.',
        cardId: 'card-01',
        lineItems: const [
          ExpenseLineItem(
            description: '96W USB-C Power Adapter',
            amount: 79.00,
          ),
          ExpenseLineItem(
            description: 'Sales Tax (NY)',
            amount: 10.00,
          ),
        ],
      ),

      // 5. Starbucks: Client Breakfast Meeting
      Expense(
        id: 'exp-105',
        merchant: 'Starbucks Coffee',
        amount: 28.50,
        currency: 'USD',
        category: 'Meals',
        date: DateTime(now.year, now.month, now.day, 8, 30),
        status: ExpenseStatus.approved,
        policyCompliant: true,
        notes: 'Client breakfast with Enterprise partner representative.',
        cardId: 'card-01',
        lineItems: const [
          ExpenseLineItem(
            description: 'Clover Brewed Reserve Coffees (2)',
            amount: 14.50,
          ),
          ExpenseLineItem(
            description: 'Breakfast Sandwiches & Pastries',
            amount: 14.00,
          ),
        ],
      ),
    ];
  }
}
