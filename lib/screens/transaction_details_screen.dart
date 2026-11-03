import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import 'transaction_form_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late TransactionModel _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  String get _amount => NumberFormat.currency(
        locale: 'en_BD',
        symbol: '৳',
        decimalDigits: 2,
      ).format(_transaction.amount);

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: _transaction),
      ),
    );
    if (changed == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text(
            'Are you sure you want to delete "${_transaction.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE35D6A)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseHelper.instance.deleteTransaction(_transaction.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _transaction.isIncome;
    final color = isIncome
        ? const Color(0xFF159D76)
        : const Color(0xFFE35D6A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEAECF3)),
            ),
            child: Column(
              children: [
                Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: color,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _transaction.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF20243A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isIncome ? '+' : '−'}$_amount',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _transaction.type,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEAECF3)),
            ),
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: _transaction.category),
                const Divider(height: 25, color: Color(0xFFF0F1F5)),
                _DetailRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Date',
                  value: DateFormat('EEEE, dd MMMM yyyy')
                      .format(_transaction.date),
                ),
                const Divider(height: 25, color: Color(0xFFF0F1F5)),
                _DetailRow(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Transaction type',
                  value: _transaction.type,
                ),
                const Divider(height: 25, color: Color(0xFFF0F1F5)),
                _DetailRow(
                  icon: Icons.tag_rounded,
                  label: 'Transaction ID',
                  value: '#${_transaction.id}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _edit,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Transaction'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5B67F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete Transaction'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE35D6A),
                side: const BorderSide(color: Color(0xFFF0C7CC)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7A8097), size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF292E43),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
