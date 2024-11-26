import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpenseScreen extends StatefulWidget {
  final String tripId;

  AddExpenseScreen({required this.tripId});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = {
        'expenseName': _expenseNameController.text,
        'cost': double.parse(_costController.text),
      };

      final budgetRef = FirebaseFirestore.instance
          .collection('budgets')
          .doc(widget.tripId);

      await budgetRef.update({
        'Expenses': FieldValue.arrayUnion([expense]),
        'totalSpent': FieldValue.increment(double.parse(_costController.text)),
        'totalLeft': FieldValue.increment(-double.parse(_costController.text)),
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _expenseNameController,
                decoration: InputDecoration(labelText: 'Expense Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(labelText: 'Cost'),
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
                onPressed: _addExpense,
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
