import 'package:employeeapp/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // 👁️ For show/hide password

  Future<void> _login(BuildContext context) async {
    String empId = _empIdController.text.trim();
    String password = _passwordController.text.trim();

    if (empId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Employee ID and Password")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("employees")
          .where("employeeId", isEqualTo: empId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var employee = snapshot.docs.first.data() as Map<String, dynamic>;

        if (employee["password"] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(employee: employee),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid Password")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Employee not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Back Button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
            ),
          ),

          // Main Card
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 12,
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_center,
                          size: 60, color: Colors.deepPurple),
                      const SizedBox(height: 10),
                      const Text(
                        "Employee Login",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Employee ID
                      TextField(
                        controller: _empIdController,
                        decoration: InputDecoration(
                          labelText: "Employee ID",
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: () {
                          _login(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text("Login"),
                      ),
                      const SizedBox(height: 12),

                      // Don't have account? Register
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
