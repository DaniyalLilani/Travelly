import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'update_budget_screen.dart';
import 'add_expense_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String? tripId;

  @override
  void initState() {
    super.initState();
    _fetchTripId();
  }

  Future<void> _fetchTripId() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot userTrips = await FirebaseFirestore.instance
          .collection('trips')
          .where('user', isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId))
          .get();

      if (userTrips.docs.isNotEmpty) {
        setState(() {
          tripId = userTrips.docs.first.id;
        });
      }
    } catch (e) {
      print("Error fetching tripId: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tripId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('trips').doc(tripId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("No budget data available."));
                }

                // Parse data
                final data = snapshot.data!.data() as Map<String, dynamic>;
                double totalBudget = data['totalBudget']?.toDouble() ?? 0.0;
                double usedBudget = data['totalSpent']?.toDouble() ?? 0.0;
                double remainingBudget = totalBudget - usedBudget;
                double remainingPercentage = totalBudget > 0
                    ? (remainingBudget / totalBudget) * 100
                    : 0.0; // Avoid division by zero
                DateTime? startDate =
                    (data['startDate'] as Timestamp?)?.toDate();
                DateTime? endDate = (data['endDate'] as Timestamp?)?.toDate();
                List<dynamic> expenseList = data['expenses'] ?? [];
                List<ExpenseItem> expenses = expenseList.map((expense) {
                  return ExpenseItem(
                    name: expense['expenseName'] ?? 'Unnamed',
                    cost: (expense['cost']?.toDouble() ?? 0.0),
                  );
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget Title
                      const Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          height: 200,
                          child: SfCircularChart(
                            series: <CircularSeries>[
                              DoughnutSeries<ChartData, String>(
                                dataSource: [
                                  ChartData('Used', usedBudget, Colors.black),
                                  ChartData(
                                      'Remaining', remainingBudget, Colors.purple),
                                ],
                                xValueMapper: (ChartData data, _) => data.label,
                                yValueMapper: (ChartData data, _) => data.value,
                                pointColorMapper: (ChartData data, _) =>
                                    data.color,
                                innerRadius: '80%',
                              ),
                            ],
                            annotations: <CircularChartAnnotation>[
                              CircularChartAnnotation(
                                widget: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Remaining',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 16),
                                    ),
                                    Text(
                                      '${remainingPercentage.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You have \$${remainingBudget.toStringAsFixed(0)} remaining out of your budget.',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start',
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                startDate != null
                                    ? '${startDate.month}/${startDate.day}/${startDate.year}'
                                    : 'N/A',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End',
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                endDate != null
                                    ? '${endDate.month}/${endDate.day}/${endDate.year}'
                                    : 'N/A',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Overall Budget',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '\$${totalBudget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateBudgetScreen(
                              tripId: tripId,
                              totalBudget: totalBudget,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Update Budget'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Expenses',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return ListTile(
                            title: Text(expense.name),
                            subtitle: Text('\$${expense.cost.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final expenseToDelete = {
                                  'expenseName': expense.name,
                                  'cost': expense.cost,
                                };
                                await FirebaseFirestore.instance
                                    .collection('trips')
                                    .doc(tripId)
                                    .update({
                                  'expenses': FieldValue.arrayRemove(
                                      [expenseToDelete]),
                                  'totalSpent': usedBudget - expense.cost,
                                  'totalLeft': totalBudget - (usedBudget - expense.cost),
                                });
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddExpenseScreen(onAdd: (name, cost) async {
                              final newExpense = {'expenseName': name, 'cost': cost};
                              await FirebaseFirestore.instance
                                  .collection('trips')
                                  .doc(tripId)
                                  .update({
                                'expenses': FieldValue.arrayUnion([newExpense]),
                                'totalSpent': usedBudget + cost,
                                'totalLeft': totalBudget - (usedBudget + cost),
                              });
                            }),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Add New Expense'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

class ExpenseItem {
  final String name;
  final double cost;

  ExpenseItem({required this.name, required this.cost});
}
