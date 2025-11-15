import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;

  // Helper function to show alerts
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // --- Handle User Login ---
  Future<void> _handleLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 1. Create a ParseUser instance with credentials (using 3 positional arguments is the most stable approach)
    final user = ParseUser(
      username, // Positional 1: username
      password, // Positional 2: password
      null, // Positional 3: email (null if not explicitly providing a different email)
    );

    // 2. Call the instance method 'login()'
    final response = await user.login();

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      _showSnackBar('Login Successful!', isError: false);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      _showSnackBar(
        response.error?.message ??
            'Login failed. Please check your credentials.',
      );
    }
  }

  // --- Handle User Registration ---
  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter a valid email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Use ParseUser.createUser() with NAMED arguments (this method is reliably correct)
    final user = ParseUser.createUser(email, password, email);
    final response = await user.signUp();

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      _showSnackBar(
        'Registration Successful! Logged in automatically.',
        isError: false,
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      _showSnackBar(response.error?.message ?? 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Register for FluBack' : 'FluBack Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Student Email ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: !_isLoading, // Disable when loading
              ),
              const SizedBox(height: 16),
              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                enabled: !_isLoading, // Disable when loading
              ),
              const SizedBox(height: 32),
              // Main Action Button (Login or Register)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isRegistering ? _handleRegister : _handleLogin),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isRegistering ? 'Register' : 'Login'),
                ),
              ),
              const SizedBox(height: 20),
              // Toggle Button
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isRegistering = !_isRegistering;
                        });
                      },
                child: Text(
                  _isRegistering
                      ? 'Already have an account? Login'
                      : 'Need an account? Register',
                  style: TextStyle(
                    color: _isLoading ? Colors.grey : Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
