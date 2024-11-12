import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'update_budget_screen.dart';
import 'add_expense_screen.dart';

class BudgetScreen extends StatelessWidget {
   double totalBudget = 1000;
   double usedBudget = 700; 
   List<ExpenseItem> expenses = [
    ExpenseItem(name: 'Transportation', cost: 350),
    ExpenseItem(name: 'Accommodation', cost: 250),
    ExpenseItem(name: 'Food', cost: 100),
  ];

  @override
  Widget build(BuildContext context) {
    double remainingBudget = totalBudget - usedBudget;
    double remainingPercentage = (remainingBudget / totalBudget) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      ChartData('Remaining', remainingBudget, Colors.purple), 
                    ],
                    xValueMapper: (ChartData data, _) => data.label,
                    yValueMapper: (ChartData data, _) => data.value,
                    pointColorMapper: (ChartData data, _) => data.color,
                    innerRadius: '80%',
                    startAngle: 180, 
                    endAngle: 540, 
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
                            color: Colors.black54,
                            fontSize: 16,
                          ),
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
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Start',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    'Tue, Oct 15',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'End',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    'Thurs, Oct 31',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Overall Budget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${totalBudget.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateBudgetScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update Budget'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Expenses',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // List of Expenses
          Column(
            children: expenses.map((expense) {
              return ListTile(
                title: Text(
                  expense.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('\$${expense.cost}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add New Expense'),
          ),
        ],
      ),
    );
  }
}

// Helper class to represent data for the pie chart
class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

// Helper class to represent an expense item
class ExpenseItem {
  final String name;
  final double cost;

  ExpenseItem({required this.name, required this.cost});
}
