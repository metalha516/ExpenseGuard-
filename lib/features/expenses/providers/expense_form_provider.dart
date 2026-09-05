import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/models/expense.dart';

/// Available business expense categories.
const List<String> kExpenseCategories = [
  'Software Subscription',
  'Meals & Entertainment',
  'Travel & Lodging',
  'Office Supplies',
  'Transit & Fuel',
  'Client Hospitality',
];

/// Immutable state for the Expense Review & OCR extraction form.
@immutable
class ExpenseFormState {
  const ExpenseFormState({
    this.isScanning = false,
    this.imagePath,
    this.merchant = '',
    this.amount = 0.0,
    this.amountText = '',
    this.date,
    this.category = 'Software Subscription',
    this.notes = '',
    this.isPolicyCompliant = true,
    this.policyMessage = "This one's all set ✅",
    this.policySubtext = 'Within monthly software budget',
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
    this.lineItems = const [],
  });

  final bool isScanning;
  final String? imagePath;
  final String merchant;
  final double amount;
  final String amountText;
  final DateTime? date;
  final String category;
  final String notes;
  final bool isPolicyCompliant;
  final String policyMessage;
  final String policySubtext;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;
  final List<ExpenseLineItem> lineItems;

  /// Returns true if merchant is non-empty, amount is greater than 0, and OCR is complete.
  bool get isValid =>
      !isScanning &&
      merchant.trim().isNotEmpty &&
      amount > 0.0 &&
      !amount.isNaN &&
      !amount.isInfinite;

  ExpenseFormState copyWith({
    bool? isScanning,
    String? imagePath,
    String? merchant,
    double? amount,
    String? amountText,
    DateTime? date,
    String? category,
    String? notes,
    bool? isPolicyCompliant,
    String? policyMessage,
    String? policySubtext,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    List<ExpenseLineItem>? lineItems,
  }) {
    return ExpenseFormState(
      isScanning: isScanning ?? this.isScanning,
      imagePath: imagePath ?? this.imagePath,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      amountText: amountText ?? this.amountText,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isPolicyCompliant: isPolicyCompliant ?? this.isPolicyCompliant,
      policyMessage: policyMessage ?? this.policyMessage,
      policySubtext: policySubtext ?? this.policySubtext,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage,
      lineItems: lineItems ?? this.lineItems,
    );
  }

  /// Converts current valid form state into a concrete domain Expense model.
  Expense toExpense({String? id}) {
    return Expense(
      id: id ?? 'exp_${DateTime.now().millisecondsSinceEpoch}',
      merchant: merchant.trim(),
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      receiptUrl: imagePath,
      status: ExpenseStatus.pending,
      policyCompliant: isPolicyCompliant,
      policyNote: policySubtext,
      notes: notes,
      lineItems: lineItems,
      createdAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseFormState &&
          runtimeType == other.runtimeType &&
          isScanning == other.isScanning &&
          imagePath == other.imagePath &&
          merchant == other.merchant &&
          amount == other.amount &&
          amountText == other.amountText &&
          date == other.date &&
          category == other.category &&
          notes == other.notes &&
          isPolicyCompliant == other.isPolicyCompliant &&
          policyMessage == other.policyMessage &&
          policySubtext == other.policySubtext &&
          isSubmitting == other.isSubmitting &&
          isSubmitted == other.isSubmitted &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        isScanning,
        imagePath,
        merchant,
        amount,
        amountText,
        date,
        category,
        isPolicyCompliant,
        isSubmitting,
        isSubmitted,
      );
}

/// Riverpod modern Notifier managing the Expense Review form lifecycle,
/// simulated OCR receipt parsing, and policy compliance verification.
class ExpenseFormNotifier extends Notifier<ExpenseFormState> {
  @override
  ExpenseFormState build() {
    return ExpenseFormState(date: DateTime.now());
  }

  /// Initialize the form with an image path and kick off simulated OCR scanning.
  Future<void> initializeWithReceipt({
    String? imagePath,
    bool autoScan = true,
    Duration? simulatedDelay,
  }) async {
    state = state.copyWith(
      imagePath: imagePath,
      isScanning: autoScan,
      errorMessage: null,
    );

    if (autoScan) {
      await simulateOcrScan(simulatedDelay: simulatedDelay);
    }
  }

  /// Simulates intelligent OCR parsing of the thermal receipt image.
  Future<void> simulateOcrScan({
    Duration? simulatedDelay,
    String defaultMerchant = 'AWS',
    double defaultAmount = 49.99,
    String defaultCategory = 'Software Subscription',
    DateTime? defaultDate,
  }) async {
    state = state.copyWith(isScanning: true, errorMessage: null);

    // Apply delay if specified or default short delay for non-test runs
    final delay = simulatedDelay ?? const Duration(milliseconds: 600);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    final parsedDate = defaultDate ?? DateTime(2023, 10, 24);
    final isCompliant = defaultAmount <= 200.0;

    state = state.copyWith(
      isScanning: false,
      merchant: defaultMerchant,
      amount: defaultAmount,
      amountText: defaultAmount.toStringAsFixed(2),
      date: parsedDate,
      category: defaultCategory,
      isPolicyCompliant: isCompliant,
      policyMessage:
          isCompliant ? "This one's all set ✅" : 'Manager Review Required ⚠️',
      policySubtext: isCompliant
          ? 'Within monthly software budget'
          : 'Expense exceeds standard \$200 limit',
      lineItems: [
        ExpenseLineItem(
          description: '$defaultMerchant Cloud Compute / Storage',
          amount: defaultAmount,
          quantity: 1,
        ),
      ],
    );
  }

  /// Updates the merchant/vendor name.
  void setMerchant(String merchant) {
    state = state.copyWith(merchant: merchant.trim());
  }

  /// Updates the expense amount from double value.
  void setAmount(double amount) {
    if (amount < 0 || amount.isNaN || amount.isInfinite) return;
    _evaluateCompliance(amount, state.category);
  }

  /// Updates amount from text input string (sanitized).
  void setAmountFromText(String text) {
    final sanitized = text.replaceAll(RegExp(r'[^\d.]'), '');
    final parsed = double.tryParse(sanitized) ?? 0.0;
    if (parsed < 0 || parsed.isNaN || parsed.isInfinite) return;

    state = state.copyWith(
      amount: parsed,
      amountText: text,
    );
    _evaluateCompliance(parsed, state.category);
  }

  /// Updates expense date.
  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Updates expense category and re-evaluates policy compliance.
  void setCategory(String category) {
    state = state.copyWith(category: category);
    _evaluateCompliance(state.amount, category);
  }

  /// Updates additional notes.
  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Evaluates corporate policy limits based on category and amount.
  void _evaluateCompliance(double amount, String category) {
    bool compliant = true;
    String message = "This one's all set ✅";
    String subtext = 'Within monthly $category budget';

    if (category == 'Software Subscription' && amount > 200.0) {
      compliant = false;
      message = 'Manager Approval Required ⚠️';
      subtext = 'Software subscription exceeds \$200.00 pre-approval threshold';
    } else if (category == 'Meals & Entertainment' && amount > 75.0) {
      compliant = false;
      message = 'Exceeds Per-Diem Meal Limit ⚠️';
      subtext = 'Individual meals are capped at \$75.00 per person';
    } else if (amount > 1000.0) {
      compliant = false;
      message = 'VP Sign-off Required ⚠️';
      subtext = 'Expenses over \$1,000 require executive pre-clearance';
    }

    state = state.copyWith(
      amount: amount,
      isPolicyCompliant: compliant,
      policyMessage: message,
      policySubtext: subtext,
    );
  }

  /// Reset form state.
  void reset() {
    state = ExpenseFormState(date: DateTime.now());
  }
}

/// Global provider for ExpenseFormNotifier.
final expenseFormProvider =
    NotifierProvider<ExpenseFormNotifier, ExpenseFormState>(
  ExpenseFormNotifier.new,
);
