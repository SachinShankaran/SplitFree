import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:splitfree/features/auth/services/auth_service.dart';
import 'package:splitfree/features/groups/models/expense_model.dart';
import 'package:splitfree/features/groups/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/group_model.dart';
import 'add_expense_screen.dart';
import '../models/settlement_model.dart'; // Add this line

// Debt model
class Debt {
  final String from;
  final String to;
  final double amount;
  Debt({required this.from, required this.to, required this.amount});
}

final expensesStreamProvider =
    StreamProvider.autoDispose.family<List<ExpenseModel>, String>((ref, groupId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getExpenses(groupId);
});

final settlementsStreamProvider =
    StreamProvider.autoDispose.family<List<Settlement>, String>((ref, groupId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSettlements(groupId);
});

class GroupDetailsScreen extends ConsumerWidget {
  final GroupModel group;
  const GroupDetailsScreen({super.key, required this.group});

  void _settleUp(BuildContext context, Debt debt) async {
    final String upiId = debt.to;
    final String amount = debt.amount.toStringAsFixed(2);
    final String note = 'Settling up for ${group.name}';
    const String currency = 'INR';

    final Uri upiUrl = Uri.parse(
      'upi://pay?pa=$upiId&pn=${debt.to.split('@')[0]}&am=$amount&cu=$currency&tn=$note',
    );

    if (!await launchUrl(upiUrl, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch payment app.')),
      );
    }
  }

  void _markAsPaid(BuildContext context, WidgetRef ref, Debt debt) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Paid'),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                const TextSpan(text: 'Are you sure you have paid '),
                TextSpan(
                  text: debt.to.split('@')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ₹${debt.amount.toStringAsFixed(2)}?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Mark as Paid'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.addSettlement(group.id, debt.from, debt.to, debt.amount);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment of ₹${debt.amount.toStringAsFixed(2)} marked as settled!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error marking payment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsyncValue = ref.watch(expensesStreamProvider(group.id));
    final settlementsAsyncValue = ref.watch(settlementsStreamProvider(group.id));
    
    final expenses = expensesAsyncValue.asData?.value ?? [];
    final settlements = settlementsAsyncValue.asData?.value ?? [];
    
    final balances = _calculateBalances(expenses, settlements);
    final simplifiedDebts = _calculateSimplifiedDebts(balances);

    final currentUserEmail = ref.watch(authServiceProvider).currentUser?.email ?? '';
    final myDebts = simplifiedDebts.where((d) => d.from == currentUserEmail).toList();

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: ListView(
        children: [
          if (myDebts.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('You Owe', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...myDebts.map((debt) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    children: [
                                      const TextSpan(text: 'You owe '),
                                      TextSpan(
                                        text: debt.to.split('@')[0],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: ' ₹${debt.amount.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _markAsPaid(context, ref, debt),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Mark as Paid'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      side: const BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _settleUp(context, debt),
                                    icon: const Icon(Icons.payment, size: 16),
                                    label: const Text('Pay Now'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('All Group Balances', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (balances.isEmpty)
                    const Text('No expenses yet to calculate balances.')
                  else
                    ...balances.entries.map((e) {
                      final email = e.key;
                      final balance = e.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(email.split('@')[0], style: Theme.of(context).textTheme.bodyLarge),
                            Text(
                              '₹${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: balance.abs() < 0.01
                                    ? Colors.grey
                                    : (balance > 0 ? Colors.green : Colors.red),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          
          // Recent Settlements Section
          if (settlements.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Recent Settlements', style: Theme.of(context).textTheme.titleLarge),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: settlements.take(5).length, // Show last 5 settlements
                itemBuilder: (context, index) {
                  final settlement = settlements[index];
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      '${settlement.from.split('@')[0]} paid ${settlement.to.split('@')[0]}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(settlement.settledAt)),
                    trailing: Text(
                      '₹${settlement.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Expense History', style: Theme.of(context).textTheme.titleLarge),
          ),
          expensesAsyncValue.when(
            data: (expenses) {
              if (expenses.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No expenses yet. Add one!'),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: expenses.length,
                itemBuilder: (context, i) {
                  final expense = expenses[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Paid by ${expense.paidBy.split('@')[0]}\n${DateFormat.yMMMd().format(expense.paidAt.toDate())}'),
                      trailing: Text('₹${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentUserEmail = ref.read(authServiceProvider).currentUser?.email ?? '';
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                group: group,
                paidByEmail: currentUserEmail,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, double> _calculateBalances(List<ExpenseModel> expenses, List<Settlement> settlements) {
    if (group.members.isEmpty) return {};
    final Map<String, double> balances = {for (var m in group.members) m: 0.0};

    // Calculate balances from expenses
    for (final expense in expenses) {
      final payer = expense.paidBy;
      final amount = expense.amount;
      final n = expense.splitAmong.length;
      if (n == 0) continue;

      final share = amount / n;
      balances[payer] = (balances[payer] ?? 0) + amount;
      for (final m in expense.splitAmong) {
        balances[m] = (balances[m] ?? 0) - share;
      }
    }

    // Adjust balances based on settlements
    for (final settlement in settlements) {
      balances[settlement.from] = (balances[settlement.from] ?? 0) + settlement.amount;
      balances[settlement.to] = (balances[settlement.to] ?? 0) - settlement.amount;
    }

    return balances;
  }

  List<Debt> _calculateSimplifiedDebts(Map<String, double> balances) {
    final List<Debt> debts = [];
    final Map<String, double> remaining = Map.from(balances);

    double maxVal() => remaining.values.reduce((a, b) => a > b ? a : b);
    double minVal() => remaining.values.reduce((a, b) => a < b ? a : b);
    String maxKey() => remaining.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    String minKey() => remaining.entries.reduce((a, b) => a.value < b.value ? a : b).key;

    while (maxVal() > 1e-6 && minVal() < -1e-6) {
      final creditor = maxKey();
      final debtor = minKey();
      final amount = remaining[creditor]! < -remaining[debtor]! ? remaining[creditor]! : -remaining[debtor]!;

      debts.add(Debt(from: debtor, to: creditor, amount: amount));
      remaining[creditor] = remaining[creditor]! - amount;
      remaining[debtor] = remaining[debtor]! + amount;
    }
    return debts;
  }
}