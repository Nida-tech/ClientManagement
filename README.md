# 🧹 Cleaning Service Management App

A Flutter + Firebase based application to manage **clients, teams, scheduling, rescheduling, and job completion** for a cleaning service business. This app is designed to make daily operations simple, visual, and efficient.

---

## 🚀 Features

### 👥 Client Management
- Add, edit, and view clients
- Store client name, phone number, address, service frequency
- Client status handling:
  - **Pending**
  - **Notified** (WhatsApp reminder sent)
  - **Confirmed**
- Search clients by **phone number**
- Status-wise filtering using colorful summary cards

---

### 📅 Scheduling & Rescheduling Logic
- Each client has a **next cleaning date**
- Automatic rescheduling after job completion:

| Monthly Cleanings | Days Added |
|------------------|------------|
| 1 time           | +30 days   |
| 2 times          | +15 days   |
| 3 times          | +10 days   |

- After job completion:
  - Client is **rescheduled**
  - Client is **removed from assigned team**
  - Client appears again in dashboard with updated date

---

### 👨‍👩‍👧‍👦 Team Management
- Create teams with:
  - Team name
  - Contact number
  - Team members
- Assign clients to teams
- View team details with:
  - Assigned clients list
  - "Job Completed" button for each client
- Edit team details anytime

---

### 📊 Dashboard
- Summary cards:
  - Total clients
  - Pending clients
  - Notified clients
  - Confirmed clients
- Real-time data using **Firestore streams**
- WhatsApp reminder integration
- Clean and responsive UI

---

### 📱 WhatsApp Integration
- Send reminder messages directly from the app
- Auto-update client status to **Notified** after sending message

---

## 🛠 Tech Stack

- **Flutter** (UI & Logic)
- **Firebase Firestore** (Database)
- **Firebase Authentication** (optional / future-ready)
- **intl** (date formatting)
- **url_launcher** (WhatsApp integration)

---

## 📂 Project Structure

```
lib/
│── models/
│   ├── client_model.dart
│   └── team_model.dart
│
│── services/
│   └── firestore_service.dart
│
│── screens/
│   ├── dashboard_screen.dart
│   ├── add_client_screen.dart
│   ├── client_detail_screen.dart
│   ├── team_list_screen.dart
│   ├── team_detail_screen.dart
│   └── edit_team_screen.dart
│
│── main.dart
```

---

## 🔥 Firestore Collections Structure

### Clients Collection
```
clients/{clientId}
  - name
  - phone
  - status
  - nextCleaningDate
  - monthlyCleanings
  - assignedTeamId (nullable)
```

### Teams Collection
```
teams/{teamId}
  - name
  - phone
  - members (List<String>)
  - assignedClients (List<String>)
```

---

## ▶️ How to Run

1. Clone the repository
```bash
git clone https://github.com/your-username/cleaning_app.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add `google-services.json`
- Enable Firestore

4. Run the app
```bash
flutter run
```

---

## 📌 Future Enhancements
- Date range filter on dashboard
- Calendar view for clients
- User roles (Admin / Team)
- Push notifications
- Analytics & reports

---

## ❤️ Author

Built with care for real-world cleaning service workflows.

If you find this useful, feel free to ⭐ the repo and contribute!

---

Happy Cleaning 🧼✨