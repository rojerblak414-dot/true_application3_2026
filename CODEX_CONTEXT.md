# GEMINI.md — Flutter Income & Expense App (json-server Edition)

> **Context file for AI assistants (Gemini, Claude, Copilot, etc.)**
> This file defines the full project context, architecture, API contract, and coding conventions
> for the **MoneyTrack** Flutter app that uses `json-server` instead of Firebase.

---

## 1. PROJECT OVERVIEW

| Field | Value |
|---|---|
| App Name | MoneyTrack (ຕິດຕາມເງິນ) |
| Platform | Flutter (Android + iOS) |
| Backend | json-server running at `http://localhost:3000` |
| Language | Dart / Flutter |
| State Mgmt | `setState` (simple, beginner-friendly) |
| Auth | Simple user login via json-server (no Firebase) |
| Currency | Lao Kip (₭) — but works for any currency |

### What the app does
- Register / Login with email + password (stored in json-server)
- Add **income** with amount + date
- Add **expenses** with amount + category (Car, Internet, Food) + date
- View **dashboard** showing:
  - Pie chart of expenses by category
  - Income / Expense / Balance summary cards
  - Recent 5 transactions list
- View **profile** (name, email)
- Logout

---

## 2. TECH STACK

```
Flutter SDK        ≥ 3.0
Dart               ≥ 3.0
http               ^1.2.0      ← replaces Firebase calls
fl_chart           ^0.68.0     ← pie chart (same as before)
shared_preferences ^2.2.0      ← store logged-in userId locally
intl               ^0.19.0     ← date formatting
json_annotation    ^4.8.1      ← optional: code-gen models
```

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  fl_chart: ^0.68.0
  shared_preferences: ^2.2.0
  intl: ^0.19.0
```

---

## 3. JSON-SERVER SETUP (Step-by-step for beginners)

### Step 1 — Install Node.js
Download from https://nodejs.org (LTS version). This gives you `npm`.

### Step 2 — Install json-server globally
```bash
npm install -g json-server
```

### Step 3 — Create `db.json` (your "database" file)
Create a folder called `moneytrack-api/` anywhere on your computer.
Inside it, create `db.json`:

```json
{
  "users": [
    {
      "id": "1",
      "name": "Demo User",
      "email": "demo@example.com",
      "password": "123456"
    }
  ],
  "expenses": [
    {
      "id": "e1",
      "userId": "1",
      "amount": 50000,
      "category": "Food",
      "createdAt": "2025-01-15"
    }
  ],
  "income": [
    {
      "id": "i1",
      "userId": "1",
      "amount": 5000000,
      "createdAt": "2025-01-01"
    }
  ]
}
```

### Step 4 — Start json-server
```bash
cd moneytrack-api
json-server --watch db.json --port 3000
```

You will see:
```
Resources
  http://localhost:3000/users
  http://localhost:3000/expenses
  http://localhost:3000/income
```

### Step 5 — Test with browser
Open http://localhost:3000/users — you should see the users array.

### Step 6 — Flutter connects to the API
- **Android emulator**: use `http://10.0.2.2:3000` (emulator's localhost)
- **iOS simulator**: use `http://localhost:3000`
- **Real device**: use your computer's LAN IP, e.g. `http://192.168.1.5:3000`

Configure in `lib/config/api_config.dart`:
```dart
class ApiConfig {
  // Change this based on your environment:
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS simulator
  // static const String baseUrl = 'http://192.168.1.5:3000'; // Real device
}
```

---

## 4. API ENDPOINTS (Full Contract)

All requests/responses use `Content-Type: application/json`.

### 4.1 Users

#### GET all users (used for login check)
```
GET /users
```
Response:
```json
[
  { "id": "1", "name": "Demo User", "email": "demo@example.com", "password": "123456" }
]
```

#### POST — Register new user
```
POST /users
Body: { "name": "string", "email": "string", "password": "string" }
```
Response: `201 Created` with the created user object (json-server auto-adds `id`).

#### Login logic (no dedicated endpoint — handled in Flutter)
```
GET /users?email=demo@example.com&password=123456
```
If the array is non-empty → login success. Save `user.id` to SharedPreferences.

---

### 4.2 Expenses

#### GET expenses for current user
```
GET /expenses?userId=<userId>
```
Response:
```json
[
  { "id": "e1", "userId": "1", "amount": 50000, "category": "Food", "createdAt": "2025-01-15" }
]
```

#### POST — Add new expense
```
POST /expenses
Body: { "userId": "string", "amount": number, "category": "string", "createdAt": "YYYY-MM-DD" }
```

#### DELETE — Remove an expense
```
DELETE /expenses/<id>
```

---

### 4.3 Income

#### GET income for current user
```
GET /income?userId=<userId>
```
Response:
```json
[
  { "id": "i1", "userId": "1", "amount": 5000000, "createdAt": "2025-01-01" }
]
```

#### POST — Add new income
```
POST /income
Body: { "userId": "string", "amount": number, "createdAt": "YYYY-MM-DD" }
```

#### DELETE — Remove income record
```
DELETE /income/<id>
```

---

## 5. PROJECT FOLDER STRUCTURE

```
lib/
├── config/
│   └── api_config.dart          ← base URL configuration
│
├── models/
│   ├── user_model.dart           ← User data class
│   ├── expense_model.dart        ← Expense data class
│   ├── income_model.dart         ← Income data class
│   └── transaction_model.dart    ← Combined model for display
│
├── services/
│   ├── auth_service.dart         ← login, register, logout
│   ├── expense_service.dart      ← CRUD for expenses
│   └── income_service.dart       ← CRUD for income
│
├── component/
│   ├── inputfield_loginpage.dart ← reusable styled TextField
│   ├── inputfileld_register.dart ← register form field
│   ├── myinfo_box.dart           ← profile info box (orange card)
│   └── mymenu_button.dart        ← orange action button
│
├── login/
│   ├── login_page.dart           ← login screen
│   └── register.dart             ← register screen
│
├── support/
│   ├── add_expense_page.dart     ← add expense form
│   ├── add_income_page.dart      ← add income form
│   └── profile_page.dart         ← user profile screen
│
├── help/
│   └── drawer.dart               ← side navigation drawer
│
└── main.dart                     ← app entry point + routes
```

---

## 6. DATA MODELS (Dart classes)

### UserModel
```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;

  UserModel({required this.id, required this.name,
             required this.email, required this.password});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'email': email, 'password': password
  };
}
```

### ExpenseModel
```dart
class ExpenseModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final DateTime createdAt;

  ExpenseModel({required this.id, required this.userId,
                required this.amount, required this.category,
                required this.createdAt});

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'].toString(),
    userId: json['userId'].toString(),
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] ?? 'Other',
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'amount': amount,
    'category': category,
    'createdAt': createdAt.toIso8601String().substring(0, 10),
  };
}
```

### IncomeModel
```dart
class IncomeModel {
  final String id;
  final String userId;
  final double amount;
  final DateTime createdAt;

  IncomeModel({required this.id, required this.userId,
               required this.amount, required this.createdAt});

  factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
    id: json['id'].toString(),
    userId: json['userId'].toString(),
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'amount': amount,
    'createdAt': createdAt.toIso8601String().substring(0, 10),
  };
}
```

### TransactionModel (for displaying in the list)
```dart
class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime createdAt;
  final bool isExpense;

  TransactionModel({required this.id, required this.amount,
                    required this.category, required this.createdAt,
                    required this.isExpense});
}
```

---

## 7. SERVICES (API calls using `http` package)

### AuthService
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';

  // LOGIN: find user by email+password
  static Future<UserModel?> login(String email, String password) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/users?email=$email&password=$password'
    );
    final res = await http.get(uri);
    final List data = jsonDecode(res.body);
    if (data.isEmpty) return null;

    final user = UserModel.fromJson(data[0]);
    // Save to local storage so we know who is logged in
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
    return user;
  }

  // REGISTER: create new user
  static Future<UserModel?> register(String name, String email, String password) async {
    // Check email not already taken
    final check = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users?email=$email')
    );
    final existing = jsonDecode(check.body) as List;
    if (existing.isNotEmpty) throw Exception('email-already-in-use');

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode != 201) throw Exception('register-failed');
    return UserModel.fromJson(jsonDecode(res.body));
  }

  // LOGOUT: clear local storage
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // GET current userId from local storage
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // GET current user info (name, email) from local storage
  static Future<Map<String, String>> getCurrentUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey) ?? 'No Name',
      'email': prefs.getString(_userEmailKey) ?? 'No Email',
    };
  }
}
```

### ExpenseService
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/expense_model.dart';

class ExpenseService {
  static Future<List<ExpenseModel>> getByUser(String userId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/expenses?userId=$userId')
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  static Future<void> add(ExpenseModel expense) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(expense.toJson()),
    );
  }

  static Future<void> delete(String id) async {
    await http.delete(Uri.parse('${ApiConfig.baseUrl}/expenses/$id'));
  }
}
```

### IncomeService
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/income_model.dart';

class IncomeService {
  static Future<List<IncomeModel>> getByUser(String userId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/income?userId=$userId')
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => IncomeModel.fromJson(e)).toList();
  }

  static Future<void> add(IncomeModel income) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/income'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(income.toJson()),
    );
  }

  static Future<void> delete(String id) async {
    await http.delete(Uri.parse('${ApiConfig.baseUrl}/income/$id'));
  }
}
```

---

## 8. KEY MIGRATION — Firebase → json-server

This table maps every original Firebase call to its new equivalent:

| Original Firebase | New json-server |
|---|---|
| `FirebaseAuth.instance.signInWithEmailAndPassword(...)` | `AuthService.login(email, password)` |
| `FirebaseAuth.instance.createUserWithEmailAndPassword(...)` | `AuthService.register(name, email, password)` |
| `FirebaseAuth.instance.signOut()` | `AuthService.logout()` |
| `FirebaseAuth.instance.currentUser?.uid` | `await AuthService.getCurrentUserId()` |
| `FirebaseAuth.instance.currentUser?.displayName` | `(await AuthService.getCurrentUserInfo())['name']` |
| `StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("expenses").where(...).snapshots(), ...)` | `FutureBuilder(future: ExpenseService.getByUser(userId), ...)` |
| `FirebaseFirestore.instance.collection("expenses").add({...})` | `ExpenseService.add(expense)` |

> **Note:** Because json-server doesn't support real-time streams, we replace
> `StreamBuilder` with `FutureBuilder`. To "refresh" data after adding a record,
> call `setState(() {})` or use a `GlobalKey` on the page.

---

## 9. NAVIGATION / ROUTING (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userId = await AuthService.getCurrentUserId();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: userId != null ? '/home' : '/',
    routes: {
      '/':      (ctx) => const LoginPage(),
      '/home':  (ctx) => const HomePage(),
    },
  ));
}
```

---

## 10. STEP-BY-STEP DEVELOPMENT PLAN

Follow these phases in order. Each phase is independently testable.

### Phase 1 — Setup (Day 1)
- [ ] Install Node.js + json-server
- [ ] Create `moneytrack-api/db.json` with sample data
- [ ] Start json-server, confirm endpoints work in browser
- [ ] Create Flutter project: `flutter create moneytrack`
- [ ] Add dependencies to `pubspec.yaml`, run `flutter pub get`
- [ ] Create `lib/config/api_config.dart`
- [ ] Verify Flutter can reach json-server: write a simple `http.get` test

### Phase 2 — Models (Day 1-2)
- [ ] Create `lib/models/user_model.dart`
- [ ] Create `lib/models/expense_model.dart`
- [ ] Create `lib/models/income_model.dart`
- [ ] Create `lib/models/transaction_model.dart`
- [ ] Test each `fromJson` / `toJson` with `print()` statements

### Phase 3 — Services (Day 2)
- [ ] Create `lib/services/auth_service.dart`
- [ ] Create `lib/services/expense_service.dart`
- [ ] Create `lib/services/income_service.dart`
- [ ] Test each service with dummy data from `main()`

### Phase 4 — Auth Screens (Day 3)
- [ ] Build `LoginPage` — calls `AuthService.login()`
- [ ] Build `RegisterPage` — calls `AuthService.register()`
- [ ] On success: navigate to `/home`; on failure: show SnackBar

### Phase 5 — Home Dashboard (Day 4-5)
- [ ] Build `HomePage` using `FutureBuilder` for expenses + income
- [ ] Compute totals, build `categoryMap`
- [ ] Render `PieChart` with `fl_chart`
- [ ] Render Income / Expense / Balance summary row
- [ ] Render last 5 transactions list

### Phase 6 — Add Transaction Screens (Day 5-6)
- [ ] Build `AddExpensePage` — category dropdown, date picker, amount field
- [ ] On submit: call `ExpenseService.add()`, then `Navigator.pop()`
- [ ] Build `AddIncomePage` — amount field, date picker
- [ ] On submit: call `IncomeService.add()`, then `Navigator.pop()`
- [ ] After pop, HomePage should refresh — trigger with `Navigator.pushReplacement` or `.then()`

### Phase 7 — Profile & Drawer (Day 6)
- [ ] Build `ProfilePage` using `AuthService.getCurrentUserInfo()`
- [ ] Build `AppDrawer` with navigation links
- [ ] Implement logout: `AuthService.logout()` → navigate to `/`

### Phase 8 — Polish (Day 7)
- [ ] Add loading spinners (`CircularProgressIndicator`) during API calls
- [ ] Add empty state messages ("No transactions yet")
- [ ] Add input validation (empty fields, negative numbers)
- [ ] Handle network errors gracefully
- [ ] Test on both Android emulator and iOS simulator

---

## 11. CODING CONVENTIONS

- Class names: `PascalCase` — `UserModel`, `ExpenseService`
- File names: `snake_case` — `user_model.dart`, `auth_service.dart`
- Widget class names follow Flutter norm (`PascalCase`) even for components
- All API calls are `async/await` wrapped in `try/catch`
- Never hardcode userId — always read from `AuthService.getCurrentUserId()`
- Use `const` constructors wherever possible
- Wrap API calls in try/catch and show `SnackBar` on errors
- Date format stored in API: `YYYY-MM-DD` (ISO 8601 date only)
- Currency displayed as: `₭ 50,000` (Lao Kip) — use `intl` for formatting

---

## 12. COMMON ERRORS AND FIXES

| Error | Cause | Fix |
|---|---|---|
| `Connection refused` | json-server not running | Run `json-server --watch db.json --port 3000` |
| `Connection refused` on Android | Using `localhost` on emulator | Use `10.0.2.2` instead |
| `Null check operator used on null` | userId is null | Check SharedPreferences has value; redirect to login |
| `type 'int' is not a subtype of type 'double'` | JSON `amount` is int | Cast with `(json['amount'] as num).toDouble()` |
| `FormatException` on date | Wrong date string format | Ensure stored as `YYYY-MM-DD` |
| Data not refreshing after add | `FutureBuilder` uses cached future | Move future to `initState`, call `setState` to rebuild |

---

## 13. SAMPLE `db.json` (Starter Data)

```json
{
  "users": [
    {
      "id": "user1",
      "name": "ທ່ານ ສົມໄຊ",
      "email": "somsai@example.com",
      "password": "123456"
    }
  ],
  "expenses": [
    { "id": "e1", "userId": "user1", "amount": 150000, "category": "Food", "createdAt": "2025-05-20" },
    { "id": "e2", "userId": "user1", "amount": 300000, "category": "Car", "createdAt": "2025-05-18" },
    { "id": "e3", "userId": "user1", "amount": 80000, "category": "Internet", "createdAt": "2025-05-15" }
  ],
  "income": [
    { "id": "i1", "userId": "user1", "amount": 5000000, "createdAt": "2025-05-01" },
    { "id": "i2", "userId": "user1", "amount": 500000, "createdAt": "2025-05-10" }
  ]
}
```

---

## 14. GLOSSARY (for beginners)

| Term | Plain meaning |
|---|---|
| `json-server` | A tool that turns a JSON file into a fake REST API. No backend coding needed. |
| `REST API` | A web address (URL) you send requests to get or save data. |
| `GET` | "Give me data" request |
| `POST` | "Save new data" request |
| `DELETE` | "Remove this data" request |
| `SharedPreferences` | Local phone storage — like a small notepad that remembers who is logged in |
| `FutureBuilder` | A Flutter widget that waits for async data and shows a spinner while loading |
| `StreamBuilder` | Like FutureBuilder but for real-time live data (Firebase uses this; json-server doesn't) |
| `userId` | A unique ID that links expenses and income to the correct user |
| `async/await` | Dart's way of handling operations that take time (like network calls) |

---

## 15. Working-tree change log (reviewed 2026-08-17)

This section records the currently uncommitted implementation changes relative
to the repository's last commit. It is a factual change log, not a claim that
the app is production-ready.

### Architecture and data layer

- Deleted the legacy `lib/service/api_service.dart` and
  `lib/income_expense_model/model.dart` files.
- Added `lib/config/api_config.dart` for JSON-server endpoint paths and the
  development base URL.
- Added dedicated models in `lib/models/`: `UserModel`, `IncomeModel`,
  `ExpenseModel`, and `TransactionModel`.
- Added `AuthService`, `IncomeService`, and `ExpenseService` in `lib/services/`.
  These use HTTP calls, SharedPreferences session details, status validation,
  and endpoint fallbacks for the legacy `income` and `transactions` resources.
- Added OCR parsing and document-type detection services using ML Kit.
- Expanded `db.json` with users, expenses, and income sample records.

### Screens and navigation

- Updated `main.dart` to select the login or home route from the saved user ID,
  and added named routes for both add-transaction screens.
- Reworked login and registration to call `AuthService` and display loading and
  validation states.
- Reworked the home screen to load user-specific income and expenses together,
  calculate totals/category data/recent transactions, and show a chart, empty,
  loading, and API-error states.
- Updated the income screen to save an amount and selected date through
  `IncomeService`.
- Updated the expense screen to load, add, edit, delete, and OCR-scan expenses.
- Updated the drawer and profile screen to read the saved user information and
  log out through `AuthService`.

### Component organization completed in this pass

- `lib/component/expense_chart_card.dart` owns the expense total, pie chart,
  category legend, and category-color selection.
- `lib/component/finance_summary_row.dart` owns the income/expense/balance
  summary cards and their add-screen callbacks.
- `lib/component/transaction_tile.dart` owns a formatted recent-transaction row.
- `lib/component/dashboard_empty_state.dart` owns reusable empty/error content
  and its optional retry action.
- `HomePage` now composes these components while retaining the dashboard data
  loading and navigation responsibilities. Its previous private widget
  implementations remain as cleanup candidates and should be removed once the
  extracted components have been visually regression-tested.

### Other working-tree changes

- Removed the obsolete commented `ExpenseModel` implementation and the unused,
  fully commented OCR confirmation page.
- Removed `assets/com.png`, `assets/vic.png`, and `assets/images/oak.jpg`.
  `AppDrawer` now uses a person icon avatar instead of the removed `oak.jpg`
  asset.
- Updated pubspec/package lockfiles and generated platform plugin registrants
  for the current dependency set, which includes ML Kit and image picking.
- Updated the widget test so it checks the current login-screen labels.
- Added `devtools_options.yaml`.

### Known constraints to resolve separately

- The JSON-server authentication flow remains a local-development mock: it
  sends and stores plaintext passwords and does not enforce record ownership.
- `ApiConfig.baseUrl` is `localhost`, which needs a device/emulator-specific
  override when the app does not run on the same machine as json-server.
- The previous component files use non-standard lowercase class/file naming;
  the components added in this pass use standard PascalCase class names and
  snake_case files. Rename the older components in a separate compatibility
  pass to avoid breaking imports all at once.
