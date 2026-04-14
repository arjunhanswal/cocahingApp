# 🎓 Coaching Manager — Flutter App

Minimal Flutter app wired to your Postman API collection.

---

## 🔧 Change the API Base URL — ONE PLACE

Open this file and update the `baseUrl`:

```
lib/core/constants/api_config.dart
```

```dart
class ApiConfig {
  // ✏️ Change this line only:
  static const String baseUrl = 'http://localhost:5000';

  // Examples:
  // static const String baseUrl = 'http://192.168.1.10:5000';   // local network
  // static const String baseUrl = 'https://api.mycoaching.com'; // production
}
```

All API calls across the entire app automatically use this URL. No other file needs to change.

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry + bottom nav shell
├── core/
│   ├── constants/
│   │   └── api_config.dart           # 🌐 BASE URL + all endpoints
│   ├── api/
│   │   ├── api_client.dart           # HTTP client (GET/POST/PUT/DELETE)
│   │   └── services.dart             # Service classes per feature
│   └── models/
│       └── models.dart               # All data models (Student, Course, etc.)
├── widgets/
│   └── app_widgets.dart              # Theme, shared widgets, helpers
└── features/
    ├── dashboard/screens/            # Dashboard with stats + chart
    ├── students/screens/             # Student list + add/edit form
    ├── courses/screens/              # Course list + add/edit form
    ├── payments/screens/             # Fees list + payment sheet + history
    └── staff/screens/                # Staff list + add/edit form
```

---

## 🚀 Setup

```bash
flutter pub get
flutter run
```

---

## 📡 API Endpoints Used

| Feature         | Method | Endpoint                          |
|----------------|--------|-----------------------------------|
| Dashboard Stats | GET    | /api/dashboard/summary            |
| Monthly Revenue | GET    | /api/dashboard/monthly            |
| Recent Students | GET    | /api/dashboard/recent-students    |
| List Students   | GET    | /api/students                     |
| Create Student  | POST   | /api/students                     |
| Update Student  | PUT    | /api/students/:id                 |
| Delete Student  | DELETE | /api/students/:id                 |
| Assign Course   | PUT    | /api/students/:id/assign-course   |
| List Courses    | GET    | /api/courses                      |
| Create Course   | POST   | /api/courses                      |
| Update Course   | PUT    | /api/courses/:id                  |
| Delete Course   | DELETE | /api/courses/:id                  |
| Add Payment     | POST   | /api/payments                     |
| Payment History | GET    | /api/payments/:studentId          |
| Fees List       | GET    | /api/fees                         |
| List Staff      | GET    | /api/staff                        |
| Create Staff    | POST   | /api/staff                        |
| Update Staff    | PUT    | /api/staff/:id                    |
| Delete Staff    | DELETE | /api/staff/:id                    |

---

## 📱 Screens

- **Dashboard** — Stat cards, monthly bar chart, recent students
- **Students** — List with search, fee progress bar, add/edit/delete
- **Courses** — List with fees, add/edit/delete
- **Fees** — Tabbed (All / Due / Paid), add payment bottom sheet, payment history
- **Staff** — List with role badges, add/edit/delete

---

## 🔒 Android Network (HTTP)

If your API runs on HTTP (not HTTPS), add to `android/app/src/main/AndroidManifest.xml`:

```xml
<application
  android:usesCleartextTraffic="true"
  ...>
```

For iOS, add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```
