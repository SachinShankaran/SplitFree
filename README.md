# SplitFree 💸

SplitFree is a simple expense-splitting application built using **Flutter and Firebase**.  
It helps users add group expenses, split bills among friends, and keep track of who owes money — similar to Splitwise.

---

## ✅ Features

- Firebase Authentication (Email/Google Login)  
- Create groups and add members  
- Add, edit, and delete expenses  
- Automatically split expenses among people  
- See who owes and who gets back  
- Firebase Firestore for real-time updates  
- Works on Android & Web using Flutter

---

## 📁 Project Structure (Basic Overview)

lib/
├── main.dart
├── screens/ # UI pages
├── models/ # Data classes
├── services/ # Firebase & auth logic
└── widgets/ # Reusable UI components

yaml
Copy code

---

## 🚀 How to Run the Project

### 1. Clone the project
```bash
git clone https://github.com/SachinShankaran/SplitFree.git
cd SplitFree
2. Install dependencies
bash
Copy code
flutter pub get
3. Firebase Setup
Place google-services.json in android/app/

firebase_options.dart is already generated (via FlutterFire CLI)

4. Run the app
bash
Copy code
flutter run -d chrome      # For Web
flutter run -d android     # For Android
📦 Build APK
bash
Copy code
flutter build apk --split-per-abi
APK files will be available in:

swift
Copy code
build/app/outputs/flutter-apk/
