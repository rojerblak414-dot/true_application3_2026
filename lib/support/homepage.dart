// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:true_application_3/support/profile_page.dart'; // เพิ่มการนำเข้า fl_chart

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

//     return Scaffold(
//       drawer: const Drawer(),
//       appBar: AppBar(
//         title: const Text("Welcome back"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.account_circle, size: 30),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ProfilePage()),
//               );
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection("expenses")
//                   .where("userId", isEqualTo: userId)
//                   .snapshots(),
//               builder: (context, expenseSnapshot) {
//                 return StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection("income")
//                       .where("userId", isEqualTo: userId)
//                       .snapshots(),
//                   builder: (context, incomeSnapshot) {
//                     // --- ส่วนการประมวลผลข้อมูล ---
//                     double totalExpenses = 0;
//                     double totalIncome = 0;
//                     // แผนที่สำหรับเก็บยอดแยกตามหมวดหมู่
//                     Map<String, double> categoryMap = {
//                       "Car": 0,
//                       "Lottery": 0,
//                       "Food": 0,
//                     };

//                     if (expenseSnapshot.hasData) {
//                       for (var doc in expenseSnapshot.data!.docs) {
//                         double amt = (doc['amount'] ?? 0).toDouble();
//                         String cat = doc['category'] ?? "Other";
//                         totalExpenses += amt;
//                         // บวกรวมยอดเข้าหมวดหมู่ที่ตรงกัน
//                         if (categoryMap.containsKey(cat)) {
//                           categoryMap[cat] = categoryMap[cat]! + amt;
//                         } else {
//                           categoryMap[cat] = amt;
//                         }
//                       }
//                     }

//                     if (incomeSnapshot.hasData) {
//                       for (var doc in incomeSnapshot.data!.docs) {
//                         totalIncome += (doc['amount'] ?? 0).toDouble();
//                       }
//                     }

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Manage your\nexpenses",
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // ส่ง categoryMap และยอดรวมไปทำกราฟ
//                         _buildExpenseCard(totalExpenses, categoryMap),

//                         const SizedBox(height: 30),
//                         _buildFinanceSummaryRow(totalIncome, totalExpenses),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- ส่วนของ Pie Chart และ % ---
//   Widget _buildExpenseCard(double total, Map<String, double> categories) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black12),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Expenses",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 "₭ ${total.toStringAsFixed(1)}",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 150,
//             child: Row(
//               children: [
//                 // แสดง Pie Chart
//                 Expanded(
//                   flex: 1,
//                   child: PieChart(
//                     PieChartData(
//                       sectionsSpace: 2,
//                       centerSpaceRadius: 30,
//                       sections: _buildPieChartSections(total, categories),
//                     ),
//                   ),
//                 ),
//                 // แสดงรายละเอียด % รายหมวดหมู่
//                 Expanded(
//                   flex: 1,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: categories.entries.map((entry) {
//                       double percentage = total > 0
//                           ? (entry.value / total) * 100
//                           : 0;
//                       return _buildCategoryItem(
//                         entry.key,
//                         "${percentage.toStringAsFixed(1)}%",
//                         _getCategoryColor(entry.key),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<PieChartSectionData> _buildPieChartSections(
//     double total,
//     Map<String, double> categories,
//   ) {
//     if (total == 0) {
//       return [
//         PieChartSectionData(
//           color: Colors.grey[300],
//           value: 1,
//           title: 'car',
//           radius: 40,
//         ),
//       ];
//     }
//     return categories.entries.map((entry) {
//       return PieChartSectionData(
//         color: _getCategoryColor(entry.key),
//         value: entry.value,
//         title: '', // ไม่แสดงชื่อในกราฟแต่แสดงใน Legend แทน
//         radius: 40,
//       );
//     }).toList();
//   }

//   Color _getCategoryColor(String category) {
//     switch (category) {
//       case "Car":
//         return Colors.orange;
//       case "Lottery":
//         return Colors.red;
//       case "Food":
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildCategoryItem(String title, String percent, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             "$title ($percent)",
//             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- ส่วนล่าง (Income / Expense Boxes) ---
//   Widget _buildFinanceSummaryRow(double income, double expense) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildFinanceInfo(
//             "Income",
//             "+ ₭ $income",
//             Colors.green,
//             Colors.blue,
//           ),
//         ),
//         const SizedBox(width: 20),
//         Expanded(
//           child: _buildFinanceInfo(
//             "Expenses",
//             "- ₭ $expense",
//             Colors.red,
//             Colors.red,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFinanceInfo(
//     String title,
//     String amount,
//     Color textColor,
//     Color lineColor,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black12),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Text(title, style: const TextStyle(fontSize: 14)),
//           Text(
//             amount,
//             style: TextStyle(
//               fontSize: 15,
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Container(height: 4, width: 40, color: lineColor),
//         ],
//       ),
//     );
//   }
// }
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:true_application_3/help/drawer.dart';
// import 'package:true_application_3/support/profile_page.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   get total => null;

//   @override
//   Widget build(BuildContext context) {
//     final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

//     return Scaffold(
//       // 1. เพิ่ม AppBar เพื่อให้มีปุ่มเมนู Drawer และปุ่ม Profile
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu, color: Colors.black),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 15),
//             child: GestureDetector(
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ProfilePage()),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: Image.asset(
//                   "assets/images/oak.jpg",
//                   height: 40,
//                   width: 40,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       drawer: const AppDrawer(),
//       backgroundColor: Colors.white,
//       // 2. ใช้ SingleChildScrollView ครอบด้านนอกสุดเพื่อกัน Overflow
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Welcome back",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 const Text(
//                   "Manage your\nexpenses",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     height: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 25),

//                 // ส่วนของ StreamBuilder ดึงข้อมูล
//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection("expenses")
//                       .where("userId", isEqualTo: userId)
//                       .snapshots(),
//                   builder: (context, expenseSnapshot) {
//                     return StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection("income")
//                           .where("userId", isEqualTo: userId)
//                           .snapshots(),
//                       builder: (context, incomeSnapshot) {
//                         double totalExpenses = 0;
//                         double totalIncome = 0;
//                         Map<String, double> categoryMap = {
//                           "Car": 0,
//                           "Lottery": 0,
//                           "Food": 0,
//                         };

//                         if (expenseSnapshot.hasData) {
//                           for (var doc in expenseSnapshot.data!.docs) {
//                             double amt = (doc['amount'] ?? 0).toDouble();
//                             String cat = doc['category'] ?? "Food";
//                             String formattedCat =
//                                 cat[0].toUpperCase() +
//                                 cat.substring(1).toLowerCase();
//                             totalExpenses += amt;
//                             if (categoryMap.containsKey(formattedCat)) {
//                               categoryMap[formattedCat] =
//                                   categoryMap[formattedCat]! + amt;
//                             } else {
//                               categoryMap["Food"] = categoryMap["Food"]! + amt;
//                             }
//                           }
//                         }

//                         if (incomeSnapshot.hasData) {
//                           for (var doc in incomeSnapshot.data!.docs) {
//                             totalIncome += (doc['amount'] ?? 0).toDouble();
//                           }
//                         }

//                         return Column(
//                           children: [
//                             _buildExpenseCard(totalExpenses, categoryMap),
//                             const SizedBox(height: 25),
//                             _buildFinanceSummaryRow(totalIncome, totalExpenses),
//                             // เพิ่มพื้นที่ว่างด้านล่างกันบัง
//                             const SizedBox(height: 50),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Widget ย่อยๆ (คงเดิมจากที่คุณแก้ไว้แต่ปรับความสวยงามเล็กน้อย) ---

//   Widget _buildExpenseCard(double total, Map<String, double> categories) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//         border: Border.all(color: Colors.black12),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Expenses",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 "₭ ${total.toStringAsFixed(1)}",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 180,
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: PieChart(
//                     PieChartData(
//                       sectionsSpace: 4,
//                       centerSpaceRadius: 35,
//                       sections: _buildPieChartSections(
//                         total,
//                         categoryMap: categories,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: categories.entries
//                         .map(
//                           (entry) => _buildCategoryItem(
//                             entry.key,
//                             "₭ ${entry.value.toStringAsFixed(0)}",
//                             _getCategoryColor(entry.key),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<PieChartSectionData> _buildPieChartSections(
//     double total, {
//     required Map<String, double> categoryMap,
//   }) {
//     if (total == 0) {
//       return [
//         PieChartSectionData(
//           color: Colors.grey[200],
//           value: 1,
//           title: '0%',
//           radius: 45,
//         ),
//       ];
//     }
//     return categoryMap.entries.where((e) => e.value > 0).map((entry) {
//       final double percentage = (entry.value / total) * 100;
//       return PieChartSectionData(
//         color: _getCategoryColor(entry.key),
//         value: entry.value,
//         title: '${percentage.toStringAsFixed(1)}%',
//         radius: 50,
//         titleStyle: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       );
//     }).toList();
//   }

//   Color _getCategoryColor(String category) {
//     if (category == "Car") return Colors.orange;
//     if (category == "Lottery") return Colors.red;
//     if (category == "Food") return Colors.blue;
//     return Colors.grey;
//   }

//   Widget _buildCategoryItem(String title, String amount, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               "$title: $amount",
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFinanceSummaryRow(double income, double expense) {
//     double total = income - expense;

//     return Row(
//       children: [
//         Expanded(
//           child: _buildFinanceInfo(
//             "Income",
//             "+ ₭ ${income.toStringAsFixed(0)}",
//             Colors.green,
//           ),
//         ),
//         const SizedBox(width: 15),
//         Expanded(
//           child: _buildFinanceInfo(
//             "Expenses",
//             "- ₭ ${expense.toStringAsFixed(0)}",
//             Colors.red,
//           ),
//         ),
//         // ເອົາລາຍຮັບລາຍຈ້າຍບວກກັນອອກເປັນ total
//         const SizedBox(width: 15),
//         Expanded(
//           child: _buildFinanceInfo(
//             "Total",
//             "${total >= 0 ? "+" : "-"} ₭ ${total.abs().toStringAsFixed(0)}",
//             total >= 0 ? Colors.blue : Colors.red,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFinanceInfo(String title, String amount, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.black12),
//       ),
//       child: Column(
//         children: [
//           Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
//           const SizedBox(height: 5),
//           FittedBox(
//             child: Text(
//               amount,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: color,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:true_application_3/component/my_builheader.dart';
import 'package:true_application_3/help/drawer.dart';
import 'package:true_application_3/support/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              my_builheader(),
              const SizedBox(height: 25),
              _buildDataStream(userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataStream(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("expenses")
          .where("userId", isEqualTo: userId)
          .snapshots(),
      builder: (context, expenseSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("income")
              .where("userId", isEqualTo: userId)
              .snapshots(),
          builder: (context, incomeSnapshot) {
            double totalExp = 0, totalInc = 0;
            Map<String, double> categoryMap = {
              "Car": 0,
              "Lottery": 0,
              "Food": 0,
            };

            if (expenseSnapshot.hasData) {
              for (var doc in expenseSnapshot.data!.docs) {
                double amt = (doc['amount'] ?? 0).toDouble();
                String cat = doc['category'] ?? "Food";
                totalExp += amt;
                if (categoryMap.containsKey(cat)) {
                  categoryMap[cat] = categoryMap[cat]! + amt;
                }
              }
            }
            if (incomeSnapshot.hasData) {
              for (var doc in incomeSnapshot.data!.docs) {
                totalInc += (doc['amount'] ?? 0).toDouble();
              }
            }

            return Column(
              children: [
                _buildExpenseCard(totalExp, categoryMap),
                const SizedBox(height: 25),
                // ສ່ວນສະຫຼຸບການເງິນ
                _buildFinanceSummaryRow(totalInc, totalExp),
                const SizedBox(height: 25),
                // ຍ້າຍປຸ່ມ This Month / This Year ມາໄວ້ບ່ອນນີ້
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _periodButton("This Month"),
                    const SizedBox(width: 15),
                    _periodButton("This Year"),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
          child: const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/oak.jpg"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(double total, Map<String, double> categories) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Expenses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "₭ ${total.toStringAsFixed(1)}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35,
                      sections: _buildPieChartSections(total, categories),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: categories.entries
                        .map(
                          (e) => _buildCategoryItem(
                            e.key,
                            "₭ ${e.value.toStringAsFixed(0)}",
                            _getCategoryColor(e.key),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    double total,
    Map<String, double> categoryMap,
  ) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey[200],
          value: 1,
          title: '0%',
          radius: 45,
        ),
      ];
    }
    return categoryMap.entries.where((e) => e.value > 0).map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${((entry.value / total) * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Car":
        return Colors.orange;
      case "Lottery":
        return Colors.red;
      case "Food":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ປ່ຽນສະເພາະໂຕນີ້ໃຫ້ເປັນສີ່ຫຼ່ຽມມົນ (Rounded Square)
  Widget _buildCategoryItem(String title, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              // ໃຊ້ BorderRadius ເພື່ອເຮັດໃຫ້ເປັນສີ່ຫຼ່ຽມມົນ (ບໍ່ແມ່ນ BoxShape.circle)
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSummaryRow(double income, double expense) {
    double total = income - expense;
    return Row(
      children: [
        Expanded(
          child: _buildFinanceInfo(
            "Income",
            "+ ₭ ${income.toStringAsFixed(0)}",
            Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFinanceInfo(
            "Expenses",
            "- ₭ ${expense.toStringAsFixed(0)}",
            Colors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFinanceInfo(
            "Total",
            "${total >= 0 ? "+" : "-"} ₭ ${total.abs().toStringAsFixed(0)}",
            total >= 0 ? Colors.blue : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _periodButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFinanceInfo(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
