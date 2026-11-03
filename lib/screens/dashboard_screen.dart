import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  double get _totalIncome => _transactions
      .where((item) => item.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  double get _totalExpense => _transactions
      .where((item) => !item.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  double get _balance => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  Future<void> _openForm({TransactionModel? transaction}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: transaction),
      ),
    );
    if (changed == true) _loadTransactions();
  }

  Future<void> _openDetails(TransactionModel transaction) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(transaction: transaction),
      ),
    );
    if (changed == true) _loadTransactions();
  }

  String _money(double value) => NumberFormat.currency(
        locale: 'en_BD',
        symbol: '৳',
        decimalDigits: 2,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF5B67F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add transaction',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTransactions,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, dd MMMM').format(DateTime.now()),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Expense Tracker',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.7,
                                color: Color(0xFF20243A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFE9EAF1)),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded,
                            color: Color(0xFF5B67F1)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(19),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF626EF5), Color(0xFF4653D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5965E8).withValues(alpha: 0.22),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CURRENT BALANCE',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text(
                          _money(_balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.insights_rounded,
                                color: Colors.white70, size: 17),
                            const SizedBox(width: 7),
                            Text(
                              '${_transactions.length} transaction${_transactions.length == 1 ? '' : 's'} recorded',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Income',
                          amount: _totalIncome,
                          icon: Icons.south_west_rounded,
                          color: const Color(0xFF159D76),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Expense',
                          amount: _totalExpense,
                          icon: Icons.north_east_rounded,
                          color: const Color(0xFFE35D6A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF20243A),
                          ),
                        ),
                      ),
                      Text('${_transactions.length} total',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_transactions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(35, 0, 35, 75),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 76,
                            width: 76,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B67F1).withValues(alpha: 0.09),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded,
                                size: 34, color: Color(0xFF5B67F1)),
                          ),
                          const SizedBox(height: 16),
                          const Text('No transactions yet',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 7),
                          Text(
                            'Add your first income or expense to start tracking your money.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade600, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 105),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = _transactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TransactionTile(
                            transaction: transaction,
                            onTap: () => _openDetails(transaction),
                          ),
                        );
                      },
                      childCount: _transactions.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
