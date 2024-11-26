
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
  double totalBudget = 0.0;
  double usedBudget = 0.0;
  List<ExpenseItem> expenses = [];
  bool loading = true;

  @override
  void initState(){
    super.initState();
    _fetchTrip();
  }


  void addExpense(ExpenseItem expense) {
    setState(() {
      expenses.add(expense);
      usedBudget += expense.cost;
    });
  }

  void deleteExpense(int index) {
    setState(() {
      usedBudget -= expenses[index].cost;
      expenses.removeAt(index);
    });
  }

  Future<void> createTrip(String userId) async {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Create a new trip document
  await firestore.collection('trips').add({
    'tripName': 'New Trip',
    'startTime': DateTime.now(),
    'totalBudget': 0,
    'totalSpent': 0,
    'totalLeft': 0,
    'expenses': [],
    'user': firestore.collection('users').doc(userId), 
  });

}


  Future<void> _fetchTrip() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        /* search if the user has a trip, if it does 
        1. Load and assign totalBudget, usedBudged, and expenses
        2. Else initialize a new trip with values of 0
        */
        final QuerySnapshot userTrips = await firestore
        .collection('trips')
        .where('user', isEqualTo: firestore.collection('users').doc(userId))
        .get();
        
        if(userTrips.docs.isEmpty){
          await createTrip(userId);
        } else{
            final DocumentSnapshot tripDoc = userTrips.docs.first; // load the trip
            setState(() {
              totalBudget = tripDoc['totalBudget'] ?? 0.0;
              usedBudget = tripDoc['totalSpent'] ?? 0.0;
              expenses = (tripDoc['expenses'] as List<dynamic>?)
                  ?.map((expense) => ExpenseItem(
                        name: expense['name'] ?? 'Unnamed',
                        cost: expense['cost']?.toDouble() ?? 0.0,
                      ))
                  .toList() ??
              [];
            });
        }
        
       
      }
    } catch (e) {
      print("Error fetching user info: $e");
    } finally{
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    double remainingBudget = totalBudget - usedBudget;
    double remainingPercentage = totalBudget > 0
        ? (remainingBudget / totalBudget) * 100
        : 0.0; // Avoid division by zero

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
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
                      ChartData(
                          'Used', usedBudget, isDarkMode ? Colors.white : Colors.black),
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
                            color: isDarkMode ? Colors.white70 : Colors.black54,
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
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  Text(
                    'Tue, Oct 15',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54),
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
          Text(
            'Overall Budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            '\$${totalBudget.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 24,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
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
              backgroundColor: isDarkMode ? Colors.white : Colors.black,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update Budget'),
          ),
          const SizedBox(height: 24),
          Text(
            'Expenses',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: expenses.asMap().entries.map((entry) {
              int index = entry.key;
              ExpenseItem expense = entry.value;
              return ListTile(
                title: Text(
                  expense.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text('\$${expense.cost}'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () => deleteExpense(index),
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
              backgroundColor: isDarkMode ? Colors.white : Colors.black,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
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
