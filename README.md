# Crossplatformapplication_FluBack_TaskManager
Task Manager application named as FluBack created using Flutter and Back4App

🚀 FluBack Task Manager App

Flutter Frontend | Back4App (BaaS) Backend | Real-Time CRUD

💡 Overview

The FluBack Task Manager is a modern, cross-platform mobile application designed to help users efficiently manage their daily tasks. This project showcases a robust, serverless architecture by pairing Flutter (for a single, high-fidelity codebase) with Back4App (a powerful Backend-as-a-Service) to handle all database operations and user authentication in the cloud.

The app achieves real-time data synchronization, meaning task updates are reflected instantly across devices without the need for manual refreshing.

✨ Key Features

User Authentication: Secure registration and login functionalities managed entirely by Back4App's built-in Parse Server.

CRUD Operations: Full support for Create, Read, Update, and Delete tasks.

Real-Time Sync: Tasks update instantaneously using Back4App's LiveQuery (WebSockets).

Data Security: Tasks are linked to the creating user using Pointers, ensuring strict data ownership.

Session Management: Secure logout and persistent sessions upon application restart.

🛠️ Technology Stack



(Category)Frontend : (Technology) Flutter (Dart) : (Purpose) UI/UX and Cross-Platform Mobile Application 

(Category)Backend  : (Technology) Back4App (Parse Server) : (Purpose) Database, Authentication, and Cloud Services

(Category)SDK  : (Technology) parse_server_sdk_flutter : (Purpose) Official SDK for Flutter/Dart integration with BaaS

(Category)Database : (Technology) Back4App Cloud Database : (Purpose) Persistent, NoSQL storage for Task and User data

📸 Screenshots

<img width="1920" height="1080" alt="Screenshot (1)" src="https://github.com/user-attachments/assets/b346161e-cf85-4ccb-9c82-95f6f5baefa2" />
<img width="1440" height="900" alt="Screenshot 2025-11-15 at 8 48 56 PM" src="https://github.com/user-attachments/assets/039c9002-ba93-4a80-ad58-8a3321cab1e1" />
<img width="1440" height="900" alt="Screenshot 2025-11-15 at 8 48 50 PM" src="https://github.com/user-attachments/assets/1a0d5395-9d54-40c7-9762-596e53a60326" />
<img width="1440" height="900" alt="Screenshot 2025-11-15 at 8 48 07 PM" src="https://github.com/user-attachments/assets/92f20cee-6fdf-4602-9d28-15877ba0accd" />



⚙️ Setup and Installation

Prerequisites

Flutter SDK: Ensure you have the Flutter framework installed and configured.

Android Studio : Ensure u have a physical Mobile device or any emulator launched to run the application

Back4App Account: You must have a free Back4App account and a running application instance to get your keys.

1. Configure Back4App Keys

This step is CRITICAL for the app to connect to the cloud database.

Log into your Back4App Dashboard.

Navigate to your app's App Settings > Security & Keys.

Copy your Application ID and Client Key.

In the Flutter project, locate the file responsible for initialization (usually main.dart or a separate services/back4app_init.dart file).

Replace the placeholder values in the initialization code:

// In your main.dart or initialization file:
final keyApplicationId = 'YOUR_APPLICATION_ID_HERE'; // <-- PASTE YOUR ID HERE
final keyClientKey = 'YOUR_CLIENT_KEY_HERE'; // <-- PASTE YOUR KEY HERE

await Parse().initialize(
  keyApplicationId,
  '[https://parseapi.back4app.com](https://parseapi.back4app.com)', // Standard Parse Server URL
  clientKey: keyClientKey,
  autoSendSessionId: true,
  debug: true,
);


2. Run the Application

Clone the Repository:

git clone [YOUR_REPOSITORY_URL] : cd fluback_task_manager


Install Dependencies:  flutter pub get


Run on Device/Emulator:  flutter run


👥 Data Model (Back4App Classes)

The backend uses two main classes:

_User (Built-in): Stores all authentication data.

Task (Custom Class):   title (String)

description (String):  isDone (Boolean)

user (Pointer to _User) - Crucial for data ownership.

![1000417403](https://github.com/user-attachments/assets/365880a6-80ea-40e6-a0a1-afff3d17a199)
![1000417401](https://github.com/user-attachments/assets/74f820ef-cb99-4ab4-93f9-4b1b7278e23f)


🤝 Contribution

Feel free to fork the repository, open issues, or submit pull requests.

📄 License

This project is licensed under the MIT License.
