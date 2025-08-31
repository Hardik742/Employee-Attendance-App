import 'package:flutter/material.dart';

class ProfileViewScreen extends StatelessWidget {
  final Map<String, dynamic> employee;

  const ProfileViewScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("Employee ID: ${employee['employeeId']}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Name: ${employee['name']}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Department: ${employee['department']}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Phone: ${employee['phone'] ?? '-'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Email: ${employee['email'] ?? '-'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Address: ${employee['address'] ?? '-'}",
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
