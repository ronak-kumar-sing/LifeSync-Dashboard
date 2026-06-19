import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/income_provider.dart';

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({super.key});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  bool _isIncome = true;
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    'Salary', 'Freelance', 'Investment', 'Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _labelController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedText,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Transaction',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildTypeToggle(),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelController,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., Coffee, Salary, Rent',
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryDropdown(),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.secondaryText),
              title: Text(
                DateFormat('MMM d, yyyy').format(_selectedDate),
                style: const TextStyle(color: AppColors.primaryText),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveEntry,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isIncome ? 'Add Income' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isIncome ? AppColors.greenAccent.withOpacity(0.3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _isIncome ? Border.all(color: AppColors.greenAccent, width: 1) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: _isIncome ? AppColors.greenAccent : AppColors.mutedText, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Income',
                      style: TextStyle(
                        color: _isIncome ? AppColors.greenAccent : AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isIncome ? AppColors.negative.withOpacity(0.3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: !_isIncome ? Border.all(color: AppColors.negative, width: 1) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove, color: !_isIncome ? AppColors.negative : AppColors.mutedText, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Expense',
                      style: TextStyle(
                        color: !_isIncome ? AppColors.negative : AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _categoryController.text.isEmpty ? 'Other' : _categoryController.text,
      decoration: const InputDecoration(labelText: 'Category'),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.primaryText),
      items: _categories.map((c) => DropdownMenuItem(
        value: c,
        child: Text(c, style: const TextStyle(color: AppColors.primaryText)),
      )).toList(),
      onChanged: (v) => _categoryController.text = v ?? 'Other',
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.greenAccent,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveEntry() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (_labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a label')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await context.read<IncomeProvider>().addEntry(
      amount: amount,
      label: _labelController.text,
      category: _categoryController.text.isEmpty ? 'Other' : _categoryController.text,
      date: _selectedDate,
      isIncome: _isIncome,
    );

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }
}
