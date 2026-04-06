import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController amountController = TextEditingController();

  // ✅ ເພີມຕົວແປຂອງ ປະຕິທິນເພື່ອເກັບວິນທີ
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ເພີ່ມລາຍຮັບ"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Image.network(
              "data:image/png;base64,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",
            ),
            const SizedBox(height: 20),

            const Text(
              "ຈຳນວນເງິນ",
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

            // ✅ ປະຕິທິນ ສາມາດກົດບອນ ໄອຄອນ ປະຕິທິນເລີຍ
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ✅
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                    size: 28,
                  ),
                  onPressed: () async {
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
                ),

                const SizedBox(width: 10),

                // ຕົວຫນັງສືບໍ່ສາມາດກົດໄດ້
                Text(
                  "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: SizedBox(
                    width: 200,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (amountController.text.isEmpty) return;

                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection("income")
                              .add({
                                "amount":
                                    double.tryParse(amountController.text) ??
                                    0.0,
                                "userId": user.uid,

                                // ບັນທືກມື້ທີເລືອກ
                                "createdAt": Timestamp.fromDate(selectedDate),
                              });

                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "ເພີ່ມ",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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
