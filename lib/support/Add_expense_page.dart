import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:true_application_3/models/expense_model.dart';
import 'package:true_application_3/services/auth_service.dart';
import 'package:true_application_3/services/expense_service.dart';
import 'package:true_application_3/services/ocr_parser_service.dart';
import 'package:true_application_3/services/document_type_detector.dart'
    show OcrDocType;

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  final List<String> categories = ['Car', 'Internet', 'Food'];

  String selectedCategory = 'Car';
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;
  bool isScanning = false;

  // ✅ เก็บรายการ expense ที่โหลดมาแสดง
  List<ExpenseModel> _expenses = [];
  bool _loadingList = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // โหลดรายการตอนเปิดหน้า
  }

  // ✅ โหลดรายการ expense จาก API
  Future<void> _loadExpenses() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return;
    try {
      final list = await ExpenseService.getByUser(userId);
      // เรียงจากใหม่ → เก่า
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) {
        setState(() {
          _expenses = list;
          _loadingList = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  // ✅ ສະແກນສະລິບ/ໃບຮັບ → ອ່ານ OCR → ຕື່ມຂໍ້ມູນລົງໃນຟອມ (ຜູ້ໃຊ້ຍັງແກ້ໄຂໄດ້ກ່ອນກົດ Add)
  Future<void> _scanSlip() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return; // ຜູ້ໃຊ້ຍົກເລີກ

    setState(() => isScanning = true);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(picked.path);
      final recognizedText = await recognizer.processImage(inputImage);
      final result = OcrParserService.parse(recognizedText);

      if (result.amount == null && result.type == OcrDocType.unknown) {
        _showMessage('ອ່ານສະລິບບໍ່ອອກ, ກະລຸນາປ້ອນຂໍ້ມູນເອງ');
        return;
      }

      setState(() {
        if (result.amount != null) {
          amountController.text = result.amount!.toStringAsFixed(0);
        }
        if (result.date != null) {
          selectedDate = result.date!;
        }
        // ຖ້າ category ທີ່ເດົາໄດ້ຍັງບໍ່ມີໃນ list, ເພີ່ມເຂົ້າໄປກ່ອນ ແລ້ວຄ່ອຍເລືອກ
        if (!categories.contains(result.suggestedCategory)) {
          categories.add(result.suggestedCategory);
        }
        selectedCategory = result.suggestedCategory;
      });
    } catch (e) {
      debugPrint('OCR scan error: $e');
      _showMessage('ສະແກນບໍ່ສຳເລັດ: $e');
    } finally {
      recognizer.close();
      if (mounted) setState(() => isScanning = false);
    }
  }

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
      await ExpenseService.add(
        ExpenseModel(
          id: '',
          userId: userId,
          amount: amount,
          category: selectedCategory,
          createdAt: selectedDate,
        ),
      );
      amountController.clear(); // ล้างช่องกรอก
      await _loadExpenses(); // รีโหลดรายการ
    } catch (_) {
      if (mounted) _showMessage('Could not save expense');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ✅ ลบ expense
  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ລົບລາຍການ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ຍົກເລີກ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ລົບ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ExpenseService.delete(id);
      await _loadExpenses();
    }
  }

  // ✅ แก้ไข expense — เปิด dialog แก้ amount + category
  Future<void> _edit(ExpenseModel expense) async {
    final editAmountController = TextEditingController(
      text: expense.amount.toStringAsFixed(0),
    );
    String editCategory = expense.category;

    // ถ้า category ของรายการนี้ไม่อยู่ใน list ให้เพิ่มเข้าไปก่อน
    if (!categories.contains(editCategory)) {
      categories.add(editCategory);
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit expence'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Amount'),
              const SizedBox(height: 6),
              TextField(
                controller: editAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Category'),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: editCategory,
                isExpanded: true,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => editCategory = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newAmount = double.tryParse(
                  editAmountController.text.trim(),
                );
                if (newAmount == null || newAmount <= 0) return;

                final userId = await AuthService.getCurrentUserId();
                if (userId != null) {
                  await ExpenseService.update(
                    ExpenseModel(
                      id: expense.id,
                      userId: userId,
                      amount: newAmount,
                      category: editCategory,
                      createdAt: expense.createdAt,
                    ),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                await _loadExpenses();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) setState(() => selectedDate = pickedDate);
  }

  void _showMessage(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            onPressed: isScanning ? null : _scanSlip,
            icon: isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  )
                : const Icon(Icons.document_scanner, color: Colors.orange),
            tooltip: 'ສະແກນສະລິບ', // Scan slip
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final controller = TextEditingController();
          final newCategory = await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Add Category'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'ຊື່ໝວດໝູ່'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  child: const Text('Add'),
                ),
              ],
            ),
          );
          if (newCategory != null &&
              newCategory.isNotEmpty &&
              !categories.contains(newCategory)) {
            setState(() {
              categories.add(newCategory);
              selectedCategory = newCategory;
            });
          }
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/come.png',
                height: 120,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shopping_bag,
                  size: 96,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Amount',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Category'),
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
                items: categories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, color: Colors.orange),
                ),
                const SizedBox(width: 8),
                Text(
                  '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
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
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            const Text(
              'ລາຍຈ່າຍທັງໝົດ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _loadingList
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                ? const Center(
                    child: Text(
                      'ຍັງບໍ່ມີລາຍການ',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _expenses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final e = _expenses[index];
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: const Icon(
                                Icons.arrow_downward,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              e.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${e.createdAt.day.toString().padLeft(2, '0')} '
                              '${_monthName(e.createdAt.month)} '
                              '${e.createdAt.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Text(
                              '- ₭${e.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _edit(e),
                                icon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _delete(e.id),
                                icon: const Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}
