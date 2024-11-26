import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetScreen extends StatelessWidget {
  final String tripId; // Assuming each budget is linked to a trip ID.

  BudgetScreen({required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('budgets')
            .doc(tripId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No budget data found.'));
          }

          final budgetData = snapshot.data!.data() as Map<String, dynamic>;
          final expenses = budgetData['Expenses'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Budget: \$${budgetData['totalBudget']}',
                      style: TextStyle(fontSize: 18)),
                  Text('Total Spent: \$${budgetData['totalSpent']}',
                      style: TextStyle(fontSize: 18)),
                  Text('Total Left: \$${budgetData['totalLeft']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Text('Expenses:', style: TextStyle(fontSize: 20)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ListTile(
                        title: Text(expense['expenseName']),
                        trailing: Text('\$${expense['cost']}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
