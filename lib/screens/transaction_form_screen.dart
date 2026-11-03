import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  static const _incomeCategories = [
    'Salary',
    'Business',
    'Freelance',
    'Investment',
    'Gift',
    'Other'
  ];
  static const _expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Housing',
    'Other'
  ];

  late String _type;
  String? _category;
  late DateTime _date;
  bool _isSaving = false;

  bool get _isEditing => widget.transaction != null;
  List<String> get _categories =>
      _type == 'Income' ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    final existing = widget.transaction;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
        text: existing == null ? '' : existing.amount.toString());
    _type = existing?.type ?? 'Expense';
    _category = existing?.category;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF5B67F1)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || !_categories.contains(_category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final record = TransactionModel(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category!,
      type: _type,
      date: _date,
    );

    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updateTransaction(record);
      } else {
        await DatabaseHelper.instance.insertTransaction(record);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save transaction: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFF5B67F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded,
                      color: Color(0xFF5B67F1), size: 27),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      _isEditing
                          ? 'Update the information below.'
                          : 'Enter the details of your transaction.',
                      style: const TextStyle(
                          color: Color(0xFF444B75),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),
            const _FieldLabel('Transaction type'),
            const SizedBox(height: 9),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.north_east_rounded),
                ),
                ButtonSegment(
                  value: 'Income',
                  label: Text('Income'),
                  icon: Icon(Icons.south_west_rounded),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() {
                  _type = selection.first;
                  if (!_categories.contains(_category)) _category = null;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: const Color(0xFFE8EAFE),
                selectedForegroundColor: const Color(0xFF4653D9),
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Monthly salary or Grocery shopping',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Title is required.'
                  : null,
            ),
            const SizedBox(height: 18),
            const _FieldLabel('Amount'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '৳  ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || !amount.isFinite || amount <= 0) {
                  return 'Enter a valid amount greater than zero.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            const _FieldLabel('Category'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Select a category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) =>
                  value == null ? 'Please select a category.' : null,
            ),
            const SizedBox(height: 18),
            const _FieldLabel('Date'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month_rounded),
                  suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                ),
                child: Text(DateFormat('dd MMMM yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isSaving
                    ? 'Saving...'
                    : _isEditing
                        ? 'Save Changes'
                        : 'Save Transaction'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5B67F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF30354B),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      );
}
