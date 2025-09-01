import 'package:employeeapp/OnboardingPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    String empId = _empIdController.text.trim();
    String name = _nameController.text.trim();
    String dept = _departmentController.text.trim();
    String password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      var existing = await FirebaseFirestore.instance
          .collection("employees")
          .doc(empId)
          .get();

      if (existing.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Employee ID already exists")),
        );
      } else {
        await FirebaseFirestore.instance
            .collection("employees")
            .doc(empId)
            .set({
          "employeeId": empId,
          "name": name,
          "department": dept,
          "password": password,
          "role": "employee",
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered Successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // 🔹 Back Button
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Onboardingpage()),
                    );
                  },
                ),
              ),
            ),

            // 🔹 Registration Form
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Employee Registration",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Employee ID
                            TextFormField(
                              controller: _empIdController,
                              decoration: const InputDecoration(
                                labelText: "Employee ID",
                                prefixIcon: Icon(Icons.badge),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Employee ID is required";
                                }
                                if (value.length < 3) {
                                  return "Employee ID must be at least 3 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Full Name
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Full Name is required";
                                }
                                if (value.length < 2) {
                                  return "Enter a valid name";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Department
                            TextFormField(
                              controller: _departmentController,
                              decoration: const InputDecoration(
                                labelText: "Department",
                                prefixIcon: Icon(Icons.apartment),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Department is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Password is required";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Register Button
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: () => _register(context),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Login Redirect
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                "Already have an account? Login",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
