import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// Import your custom screens (You'll create these later)
import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart';

// --- Back4App Configuration ---
// !! REPLACE these with your actual keys from the Back4App Dashboard !!
const String keyApplicationId =
    '6XvhrMH8mwy8CddEObWY01ZJtW2OQM51rH1xCdwp'; // From Back4App
const String keyClientKey =
    'zXAaccVff02FpNBZ4cxzPg3HhrTbUQwd6PFofWfc'; // From Back4App
const String keyParseServerUrl = 'https://parseapi.back4app.com/';
// -----------------------------

void main() async {
  // Ensure Flutter binding is initialized before making asynchronous calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Back4App (Parse) SDK
  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true, // Recommended for authenticated users
    debug: true, // Set to false for production release
  );

  runApp(const TaskManagerApp());
}

// --- Main Application Widget ---
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluBack Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3:
            false, // Optional: Set to true if using Material 3 features
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialScreen(), // Checks authentication status
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const TaskListScreen(),
        // Add '/register' route here once created
      },
    );
  }
}

// --- Authentication Checker Screen ---
// This widget determines whether to show the Login or Home screen
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  // Function to check if a user is currently logged in
  Future<bool> _isUserLoggedIn() async {
    // Check for a stored user/session
    final currentUser = await ParseUser.currentUser();
    // Use ParseUser.getCurrentUserLazily() for faster check if needed,
    // but ParseUser.currentUser() is comprehensive.
    return currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking authentication status
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // Decide navigation based on login status
          if (snapshot.data == true) {
            // User is logged in, navigate to the Task List
            // Note: Using an immediate replacement to prevent back navigation to InitialScreen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/home');
            });
            return Container(); // Return empty container while navigating
          } else {
            // No user logged in, show the Login screen
            return const LoginScreen();
          }
        }
      },
    );
  }
}
