import 'package:flutter/material.dart';
import 'package:true_application_3/models/income_model.dart';
import 'package:true_application_3/services/auth_service.dart';
import 'package:true_application_3/services/income_service.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController amountController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

  Future<void> _save() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount');
      return;
    }

    final userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      if (mounted)
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      return;
    }

    setState(() => isSaving = true);
    try {
      await IncomeService.add(
        IncomeModel(
          id: '',
          userId: userId,
          amount: amount,
          createdAt: selectedDate,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) _showMessage('Could not save income');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add income')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Image.asset(
              'assets/images/in.png',
              height: 140,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.attach_money, size: 96, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              'Amount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: amountController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                    size: 28,
                  ),
                  onPressed: _pickDate,
                ),
                const SizedBox(width: 10),
                Text(
                  '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 200,
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
