import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBudgetScreen extends StatefulWidget {
  final String tripId;

  UpdateBudgetScreen({required this.tripId});

  @override
  _UpdateBudgetScreenState createState() => _UpdateBudgetScreenState();
}

class _UpdateBudgetScreenState extends State<UpdateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _budgetController = TextEditingController();

  Future<void> _updateBudget() async {
    if (_formKey.currentState!.validate()) {
      final newBudget = double.parse(_budgetController.text);

      final budgetRef = FirebaseFirestore.instance
          .collection('budgets')
          .doc(widget.tripId);

      final snapshot = await budgetRef.get();
      if (snapshot.exists) {
        final currentData = snapshot.data() as Map<String, dynamic>;
        final totalSpent = currentData['totalSpent'] ?? 0.0;

        await budgetRef.update({
          'totalBudget': newBudget,
          'totalLeft': newBudget - totalSpent,
        });

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(labelText: 'Total Budget'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null)
                    return 'Must be a valid number';
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateBudget,
                child: Text('Update Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
