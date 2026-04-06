import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = "Car";

  final List<String> categories = ["Car", "Lottery", "Food"];
  //ສ້າງຕົວແປຂອງວັນທີຂອງປະຕິທິນ
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ເພີ່ມລາຍຈ້າຍ")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.network(
                "data:image/png;base64,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",

                height: 120,
              ),
            ),

            const SizedBox(height: 30),

            const Text("Enter Amount"),
            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "ຈຳນວນ",
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Enter Category"),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                items: categories.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),
            //ສວນທີເລືອກວັນທີ
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 15),

                Text(
                  "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (amountController.text.isEmpty) return;

                      await FirebaseFirestore.instance.collection("expenses").add({
                        "amount": double.parse(amountController.text),
                        "category": selectedCategory,
                        "userId": FirebaseAuth.instance.currentUser!.uid,
                        "createdAt": Timestamp.now(),
                        // ignore: equal_keys_in_map ບັນທືກມື້ທີເຫຼີອ ກຽວກັບປະຕິທິນ
                        "createdAt": Timestamp.fromDate(selectedDate),
                      });

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    child: const Text(
                      "ເພີ່ມ",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
