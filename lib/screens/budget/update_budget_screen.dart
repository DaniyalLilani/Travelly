import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBudgetScreen extends StatefulWidget {
  final String? tripId;
  final double totalBudget;

  const UpdateBudgetScreen({Key? key, required this.tripId, required this.totalBudget}) : super(key: key);

  @override
  _UpdateBudgetScreenState createState() => _UpdateBudgetScreenState();
}

class _UpdateBudgetScreenState extends State<UpdateBudgetScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _budgetController.text = widget.totalBudget.toStringAsFixed(2);
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (widget.tripId != null) {
      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).update({
        'totalBudget': double.tryParse(_budgetController.text) ?? 0.0,
        'startDate': _startDateController.text.isNotEmpty ? DateTime.parse(_startDateController.text) : null,
        'endDate': _endDateController.text.isNotEmpty ? DateTime.parse(_endDateController.text) : null,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Budget',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Budget here',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.bold, // Added bold style for the hint text
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startDateController,
              readOnly: true,
              onTap: () => _selectDate(context, _startDateController),
              decoration: InputDecoration(
                labelText: 'Start Date',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Enter start date',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.purple),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endDateController,
              readOnly: true,
              onTap: () => _selectDate(context, _endDateController),
              decoration: InputDecoration(
                labelText: 'End Date',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Enter end date',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.purple),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
