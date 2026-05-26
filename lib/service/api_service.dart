// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:true_application_3/income_expense_model/model.dart';

// // class TransactionService {
// //   // ✅ เปลี่ยนเป็น localhost สำหรับ Web
// //   static const String baseUrl = "http://localhost:3001";

// //   Future<List<TransactionModel>> getExpenses(String userId) async {
// //     final res = await http.get(Uri.parse("$baseUrl/expenses?userId=$userId"));
// //     if (res.statusCode == 200) {
// //       final List data = jsonDecode(res.body);
// //       return data.map((e) => TransactionModel.fromJson(e, true)).toList();
// //     }
// //     throw Exception("โหลด expenses ไม่สำเร็จ");
// //   }

// //   Future<List<TransactionModel>> getIncome(String userId) async {
// //     final res = await http.get(Uri.parse("$baseUrl/income?userId=$userId"));
// //     if (res.statusCode == 200) {
// //       final List data = jsonDecode(res.body);
// //       return data.map((e) => TransactionModel.fromJson(e, false)).toList();
// //     }
// //     throw Exception("โหลด income ไม่สำเร็จ");
// //   }
// // }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   // เปลี่ยนเป็น URL API จริงของคุณ (ถ้าทดสอบใน Emulator ของ Android มักใช้ http://10.0.2.2:your_port)
//   static const String baseUrl = "https://your-api-domain.com/api";

//   // เก็บ Token หรือข้อมูล User ชั่วคราวหลังจาก Login สำเร็จ
//   static String? token;
//   static Map<String, dynamic>? currentUser;

//   // 1. ฟังก์ชันเข้าสู่ระบบ (Login)
//   static Future<Map<String, dynamic>> login(
//     String email,
//     String password,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         token = data['token']; // เก็บ JWT Token ไว้ใช้ต่อ
//         currentUser = data['user']; // เก็บข้อมูล User เช่น name, email
//         return {'success': true, 'message': 'สำเร็จ'};
//       } else {
//         return {
//           'success': false,
//           'message': data['message'] ?? 'อีเมวຫຼືລະຫັດບໍ່ຖືກຕ້ອງ',
//         };
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'เชื่อมต่อเซิร์ฟเวอร์ล้มเหลว'};
//     }
//   }

//   // 2. ฟังก์ชันลงทะเบียน (Register)
//   static Future<Map<String, dynamic>> register(
//     String name,
//     String email,
//     String password,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'name': name, 'email': email, 'password': password}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return {'success': true, 'message': 'ສະມັກສະມາຊິກສຳເລັດ'};
//       } else {
//         return {
//           'success': false,
//           'message': data['message'] ?? 'ເກີດຂໍ້ຜິດພາດ',
//         };
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'เชื่อมต่อเซิร์ฟเวอร์ล้มเหลว'};
//     }
//   }

//   // 3. ฟังก์ชันออกจากระบบ (Logout)
//   static void logout() {
//     token = null;
//     currentUser = null;
//   }
//   // เพิ่มฟังก์ชันเหล่านี้เข้าไปในคลาส ApiService ของเดิมครับ

//   // 4. ฟังก์ชันดึงข้อมูลรายรับ-รายจ่ายทั้งหมดของ User
//   static Future<Map<String, dynamic>?> fetchTransactions() async {
//     try {
//       // ส่ง Token แนบไปด้วยหากหลังบ้านของคุณต้องการใช้ตรวจสอบสิทธิ์ (Authorization)
//       final response = await http.get(
//         Uri.parse('$baseUrl/transactions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//         /* คาดหวังรูปแบบ JSON ที่ส่งกลับมาจากหลังบ้านดังนี้:
//         {
//           "expenses": [{"amount": 50000, "category": "Food", "createdAt": "2026-05-24T10:00:00Z"}],
//           "income": [{"amount": 150000, "createdAt": "2026-05-24T09:00:00Z"}]
//         }
//         */
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   // 5. ฟังก์ชันเพิ่มข้อมูลรายรับ (Add Income)
//   static Future<bool> addIncome(double amount, DateTime date) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/income'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'amount': amount,
//           'createdAt': date
//               .toIso8601String(), // แปลงวันที่เป็น String format สากล
//         }),
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   // 6. ฟังก์ชันเพิ่มข้อมูลรายจ่าย (Add Expense)
//   static Future<bool> addExpense(
//     double amount,
//     String category,
//     DateTime date,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/expenses'), // ปรับ URL Endpoint ตามหลังบ้านของคุณ
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'amount': amount,
//           'category': category,
//           'createdAt': date
//               .toIso8601String(), // แปลงวันที่เป็น String format สากล
//         }),
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }
// }
