import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  const ProfileScreen({super.key, required this.employee});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = true;
  bool isEditing = true;
  Map<String, dynamic> details = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    var doc = await FirebaseFirestore.instance
        .collection('employees')
        .doc(widget.employee['employeeId'])
        .get();

    if (doc.exists) {
      details = doc.data()!;
      phoneController.text = details['phone'] ?? '';
      emailController.text = details['email'] ?? '';
      addressController.text = details['address'] ?? '';

      if (details['phone'] != null ||
          details['email'] != null ||
          details['address'] != null) {
        isEditing = false;
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance
        .collection('employees')
        .doc(widget.employee['employeeId'])
        .set({
      'phone': phoneController.text,
      'email': emailController.text,
      'address': addressController.text,
    }, SetOptions(merge: true));

    setState(() {
      details['phone'] = phoneController.text;
      details['email'] = emailController.text;
      details['address'] = addressController.text;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully!")),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(title,
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
          value.isNotEmpty ? value : "-",
          style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 2,
        backgroundColor: Colors.deepPurple,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: isEditing
            ? SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.deepPurple.shade200,
                child: const Icon(Icons.person,
                    size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(widget.employee['name'],
                  style: GoogleFonts.robotoSlab(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  labelStyle: GoogleFonts.lato(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.lato(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  labelStyle: GoogleFonts.lato(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  onPressed: _saveProfile,
                  label: Text(
                    "Save",
                    style: GoogleFonts.lato(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        )
            : ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.deepPurple.shade200,
                child: const Icon(Icons.person,
                    size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(widget.employee['name'],
                  style: GoogleFonts.robotoSlab(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            _buildProfileTile(
              icon: Icons.badge,
              title: "Employee ID",
              value: widget.employee['employeeId'],
            ),
            _buildProfileTile(
              icon: Icons.work,
              title: "Department",
              value: widget.employee['department'],
            ),
            _buildProfileTile(
              icon: Icons.phone,
              title: "Phone",
              value: details['phone'] ?? "",
            ),
            _buildProfileTile(
              icon: Icons.email,
              title: "Email",
              value: details['email'] ?? "",
            ),
            _buildProfileTile(
              icon: Icons.home,
              title: "Address",
              value: details['address'] ?? "",
            ),
          ],
        ),
      ),
    );
  }
}
