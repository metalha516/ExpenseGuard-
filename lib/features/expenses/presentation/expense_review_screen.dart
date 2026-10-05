import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/expenses/providers/expense_form_provider.dart';
import 'package:expense_guard/features/shared/presentation/animations/pastel_tap_scale.dart';

/// Screen for reviewing extracted receipt data, merchant, category, and amounts
/// based on Stitch Screen ID: 1d0c2434346c465181dde6bf14be8a53 ("Pastel Flat").
class ExpenseReviewScreen extends ConsumerStatefulWidget {
  const ExpenseReviewScreen({
    super.key,
    this.imagePath,
    this.autoScan = true,
  });

  /// The captured receipt file path passed from the Camera flow.
  final String? imagePath;

  /// Whether to automatically simulate OCR scanning upon initialization.
  final bool autoScan;

  @override
  ConsumerState<ExpenseReviewScreen> createState() =>
      _ExpenseReviewScreenState();
}

class _ExpenseReviewScreenState extends ConsumerState<ExpenseReviewScreen> {
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController();
    _amountController = TextEditingController();

    // Determine if running inside automated widget tests
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(expenseFormProvider.notifier);
      notifier.initializeWithReceipt(
        imagePath: widget.imagePath,
        autoScan: widget.autoScan,
        simulatedDelay: isTest ? Duration.zero : const Duration(milliseconds: 700),
      );
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _syncControllers(ExpenseFormState state) {
    if (!state.isScanning) {
      if (_merchantController.text != state.merchant) {
        _merchantController.text = state.merchant;
      }
      final formattedAmount = state.amount > 0 ? state.amount.toStringAsFixed(2) : '';
      if (_amountController.text != formattedAmount && state.amount > 0) {
        _amountController.text = formattedAmount;
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
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
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate(BuildContext context, ExpenseFormState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.pastelColors.mint,
              onPrimary: context.pastelColors.borderDark,
              surface: Theme.of(context).cardColor,
              onSurface: context.pastelColors.borderDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(expenseFormProvider.notifier).setDate(picked);
    }
  }

  void _showCategorySelector(BuildContext context, ExpenseFormState state) {
    final colors = context.pastelColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.borderDark, width: 2.0),
          ),
          padding: const EdgeInsets.all(AppTheme.marginMobile),
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
                  Text('Select Expense Category', style: context.headlineMd),
                  const SizedBox(height: 12),
                  ...kExpenseCategories.map((category) {
                    final isSelected = category == state.category;
                    return InkWell(
                      key: Key('category_item_$category'),
                      onTap: () {
                        ref.read(expenseFormProvider.notifier).setCategory(category);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.peachDim : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? colors.borderDark : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category,
                              style: context.bodyLg.copyWith(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_rounded, color: colors.borderDark, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitExpense(ExpenseFormState state) {
    if (!state.isValid) return;

    final expense = ref.read(expenseFormProvider).toExpense();
    context.push('/policy-check', extra: expense);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final formState = ref.watch(expenseFormProvider);

    // Sync controllers on state changes
    _syncControllers(formState);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              key: const Key('expense_review_close_button'),
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.cardSurface,
                  border: Border.all(color: colors.borderDark, width: 1.5),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: colors.borderDark,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Expense Review',
          style: context.headlineMd.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.marginMobile,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Review & Edit Details',
                      style: context.headlineMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Verify merchant, category, and amounts before submission',
                      style: context.bodyMd.copyWith(
                        color: colors.borderDark.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Captured Image Path Indicator
                    if (formState.imagePath != null && formState.imagePath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          key: const Key('reviewed_receipt_image_badge'),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.mintDim,
                            borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                            border: Border.all(
                              color: colors.borderDark,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 16, color: colors.borderDark),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  formState.imagePath!,
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

                    // 1. Receipt Thumbnail Container (w-40 h-56 -> 160 x 224)
                    _buildReceiptThumbnail(colors, formState),
                    const SizedBox(height: 20),

                    // 2. Total Amount Display Hero
                    Text(
                      'TOTAL AMOUNT',
                      style: context.metadataText.copyWith(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w800,
                        color: colors.borderDark.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formState.isScanning
                          ? '\$--.--'
                          : '\$${formState.amount.toStringAsFixed(2)}',
                      key: const Key('expense_amount_display'),
                      style: context.displayCurrency.copyWith(
                        color: colors.borderDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Form Fields (Vendor, Category, Date, Amount)
                    _buildVendorField(colors, formState),
                    const SizedBox(height: 12),
                    _buildCategoryField(colors, formState),
                    const SizedBox(height: 12),
                    _buildDateField(colors, formState),
                    const SizedBox(height: 12),
                    _buildAmountInputField(colors, formState),
                    const SizedBox(height: 24),

                    // 4. Policy Compliance Card
                    _buildPolicyCard(colors, formState),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 5. Fixed Bottom Action Area (Submit Button)
            _buildBottomActionBar(colors, formState),
          ],
        ),
      ),
    );
  }

  /// Builds the stylized thermal paper receipt preview thumbnail.
  Widget _buildReceiptThumbnail(
    AppPastelColors colors,
    ExpenseFormState state,
  ) {
    final imagePath = state.imagePath;
    final hasValidLocalFile =
        imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();

    return Center(
      child: Container(
        key: const Key('receipt_thumbnail_container'),
        width: 160,
        height: 224,
        decoration: BoxDecoration(
          color: colors.cardSurfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: colors.borderDark, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: colors.borderDark.withValues(alpha: 0.12),
              offset: const Offset(3, 4),
              blurRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Receipt Content / Fallback
            if (hasValidLocalFile)
              Image.file(File(imagePath), fit: BoxFit.cover)
            else
              _buildStylizedReceiptPaper(colors, state),

            // Scanning Laser Line Overlay
            if (state.isScanning)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.mint.withValues(alpha: 0.2),
                        colors.mint.withValues(alpha: 0.4),
                        colors.mint.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Scan Status Pill Badge
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                key: const Key('receipt_status_badge'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: state.isScanning ? colors.peach : colors.skyBlue,
                  borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                  border: Border.all(color: colors.borderDark, width: 1.0),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.isScanning) ...[
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(colors.borderDark),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Scanning...',
                          style: context.metadataText.copyWith(
                            color: colors.borderDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.document_scanner_rounded,
                          size: 14,
                          color: colors.borderDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Extracted',
                          style: context.metadataText.copyWith(
                            color: colors.borderDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stylized thermal paper receipt mockup for simulators/offline tests.
  Widget _buildStylizedReceiptPaper(
    AppPastelColors colors,
    ExpenseFormState state,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, color: colors.borderDark, size: 26),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 40,
            color: colors.borderDark.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 8),
          Text(
            state.merchant.isNotEmpty ? state.merchant : 'AWS Cloud',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(state.date),
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.black12,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Compute / Storage',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '\$${state.amount > 0 ? state.amount.toStringAsFixed(2) : "49.99"}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Barcode illusion
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              12,
              (index) => Container(
                width: index % 3 == 0 ? 3 : 1.5,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 24), // padding for extracted badge
        ],
      ),
    );
  }

  /// Vendor / Merchant Input Field with Lavender accent circle.
  Widget _buildVendorField(AppPastelColors colors, ExpenseFormState state) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.borderDark, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendor',
            style: context.metadataText.copyWith(
              color: colors.borderDark.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.lavender,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.borderDark, width: 1.0),
                ),
                child: Icon(
                  Icons.cloud_rounded,
                  color: colors.borderDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('expense_vendor_input'),
                  controller: _merchantController,
                  enabled: !state.isScanning,
                  style: context.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.borderDark,
                  ),
                  decoration: InputDecoration(
                    hintText: state.isScanning ? 'Scanning vendor...' : 'Enter vendor',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) =>
                      ref.read(expenseFormProvider.notifier).setMerchant(val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Category Selection Field with Peach accent circle and modal launcher.
  Widget _buildCategoryField(AppPastelColors colors, ExpenseFormState state) {
    return InkWell(
      key: const Key('expense_category_selector'),
      onTap: state.isScanning ? null : () => _showCategorySelector(context, state),
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: colors.borderDark, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: context.metadataText.copyWith(
                color: colors.borderDark.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.peach,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderDark, width: 1.0),
                  ),
                  child: Icon(
                    Icons.devices_rounded,
                    color: colors.borderDark,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.category,
                    style: context.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.borderDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.borderDark.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Date Selection Field with Sky Blue accent circle and date picker launcher.
  Widget _buildDateField(AppPastelColors colors, ExpenseFormState state) {
    return InkWell(
      key: const Key('expense_date_selector'),
      onTap: state.isScanning ? null : () => _selectDate(context, state),
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: colors.borderDark, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: context.metadataText.copyWith(
                color: colors.borderDark.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.skyBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderDark, width: 1.0),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: colors.borderDark,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDate(state.date),
                    style: context.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.borderDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_calendar_rounded,
                  color: colors.borderDark.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Amount Input Field with Mint accent circle.
  Widget _buildAmountInputField(
    AppPastelColors colors,
    ExpenseFormState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.borderDark, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount (\$)',
            style: context.metadataText.copyWith(
              color: colors.borderDark.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.borderDark, width: 1.0),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  color: colors.borderDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('expense_amount_input'),
                  controller: _amountController,
                  enabled: !state.isScanning,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: context.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.borderDark,
                  ),
                  decoration: InputDecoration(
                    hintText: state.isScanning ? '0.00' : '49.99',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) =>
                      ref.read(expenseFormProvider.notifier).setAmountFromText(val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Policy Check preview banner matching the Stitch design.
  Widget _buildPolicyCard(AppPastelColors colors, ExpenseFormState state) {
    final isCompliant = state.isPolicyCompliant;

    return Container(
      key: const Key('expense_policy_card'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCompliant ? colors.mintDim : colors.peachDim,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.borderDark, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompliant ? colors.mint : colors.peach,
              shape: BoxShape.circle,
              border: Border.all(color: colors.borderDark, width: 1.0),
            ),
            child: Icon(
              isCompliant
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: colors.borderDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.policyMessage,
                  style: context.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.borderDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.policySubtext,
                  style: context.bodyMd.copyWith(
                    color: colors.borderDark.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fixed bottom button bar with Submit action.
  Widget _buildBottomActionBar(
    AppPastelColors colors,
    ExpenseFormState state,
  ) {
    final canSubmit = state.isValid;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(
          top: BorderSide(
            color: colors.borderDark.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.marginMobile,
        vertical: 14,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: PastelTapScale(
          enabled: canSubmit,
          scaleDown: 0.96,
          child: ElevatedButton(
            key: const Key('expense_submit_button'),
            onPressed: canSubmit ? () => _submitExpense(state) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primarySage,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colors.borderDark.withValues(alpha: 0.2),
              disabledForegroundColor: colors.borderDark.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: canSubmit ? colors.borderDark : Colors.transparent,
                  width: 1.5,
                ),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Submit',
                  style: context.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: canSubmit ? Colors.white : colors.borderDark.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: canSubmit ? Colors.white : colors.borderDark.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
