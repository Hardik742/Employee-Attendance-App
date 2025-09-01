import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final CollectionReference employees =
  FirebaseFirestore.instance.collection("employees");

  String searchQuery = "";
  String filterDept = "All";

  // 🔹 Delete Employee
  void _deleteEmployee(BuildContext context, String empId) {
    employees.doc(empId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Employee deleted successfully")),
      );
    });
  }

  // 🔹 Add / Edit Employee Dialog
  void _showEmployeeDialog(BuildContext context,
      {String? empId,
        String? name,
        String? email,
        String? phone,
        String? department}) {
    final idController = TextEditingController(text: empId ?? "");
    final nameController = TextEditingController(text: name ?? "");
    final emailController = TextEditingController(text: email ?? "");
    final phoneController = TextEditingController(text: phone ?? "");
    final departmentController =
    TextEditingController(text: department ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          empId == null ? "Add Employee" : "Edit Employee",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Employee ID", idController, empId == null),
              _buildTextField("Name", nameController),
              _buildTextField("Email", emailController),
              _buildTextField("Phone", phoneController),
              _buildTextField("Department", departmentController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              String newId = idController.text.trim();
              String newName = nameController.text.trim();
              String newEmail = emailController.text.trim();
              String newPhone = phoneController.text.trim();
              String newDept = departmentController.text.trim();

              if (newId.isNotEmpty && newName.isNotEmpty) {
                if (empId == null) {
                  employees.doc(newId).set({
                    "name": newName,
                    "email": newEmail,
                    "phone": newPhone,
                    "department": newDept,
                  });
                } else {
                  employees.doc(empId).update({
                    "name": newName,
                    "email": newEmail,
                    "phone": newPhone,
                    "department": newDept,
                  });
                }
                Navigator.pop(ctx);
              }
            },
            child: Text("Save", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 Custom textfield builder
  Widget _buildTextField(String label, TextEditingController controller,
      [bool enabled = true]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // 🔹 Employee Profile View
  void _showProfile(
      BuildContext context, Map<String, dynamic> emp, String empId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(emp["name"] ?? "Employee",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🆔 ID: $empId", style: GoogleFonts.roboto()),
            Text("📧 Email: ${emp["email"] ?? "N/A"}",
                style: GoogleFonts.roboto()),
            Text("📞 Phone: ${emp["phone"] ?? "N/A"}",
                style: GoogleFonts.roboto()),
            Text("🏢 Department: ${emp["department"] ?? "N/A"}",
                style: GoogleFonts.roboto()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Close", style: GoogleFonts.poppins()),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Employees",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          // 🔎 Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or ID...",
                hintStyle: GoogleFonts.roboto(),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // ⬇️ Filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.deepPurple),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: filterDept,
                  style: GoogleFonts.poppins(color: Colors.black),
                  items: const [
                    DropdownMenuItem(
                        value: "All", child: Text("All Departments")),
                    DropdownMenuItem(value: "HR", child: Text("HR")),
                    DropdownMenuItem(value: "IT", child: Text("IT")),
                    DropdownMenuItem(value: "Finance", child: Text("Finance")),
                    DropdownMenuItem(value: "Sales", child: Text("Sales")),
                    DropdownMenuItem(value: "Developer", child: Text("Developer")),
                    DropdownMenuItem(
                        value: "Marketing", child: Text("Marketing")),
                    DropdownMenuItem(
                        value: "Operations", child: Text("Operations")),
                    DropdownMenuItem(
                        value: "Research & Development (R&D)",
                        child: Text("Research & Development (R&D)")),
                    DropdownMenuItem(
                        value: "Manufacturing", child: Text("Manufacturing")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      filterDept = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          // 👨‍💼 Employee list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: employees.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text("No Employees Found",
                          style: GoogleFonts.poppins()));
                }

                var employeeList = snapshot.data!.docs;

                // Apply search + filter
                var filtered = employeeList.where((doc) {
                  var emp = doc.data() as Map<String, dynamic>;
                  String name = (emp["name"] ?? "").toLowerCase();
                  String dept = (emp["department"] ?? "");
                  String id = doc.id.toLowerCase();

                  bool matchesSearch =
                      name.contains(searchQuery) || id.contains(searchQuery);
                  bool matchesFilter =
                      filterDept == "All" || dept == filterDept;

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                      child: Text("No results match your search/filter",
                          style: GoogleFonts.poppins()));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var empDoc = filtered[index];
                    String empId = empDoc.id;
                    var emp = empDoc.data() as Map<String, dynamic>;

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: const Icon(Icons.person,
                              color: Colors.deepPurple),
                        ),
                        title: Text("${emp["name"] ?? "Unnamed"} (ID: $empId)",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📧 ${emp["email"] ?? "No email"}",
                                style: GoogleFonts.roboto(fontSize: 13)),
                            Text("📞 ${emp["phone"] ?? "No phone"}",
                                style: GoogleFonts.roboto(fontSize: 13)),
                            Text("🏢 ${emp["department"] ?? "No department"}",
                                style: GoogleFonts.roboto(fontSize: 13)),
                          ],
                        ),
                        onTap: () => _showProfile(context, emp, empId),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEmployeeDialog(
                                context,
                                empId: empId,
                                name: emp["name"],
                                email: emp["email"],
                                phone: emp["phone"],
                                department: emp["department"],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEmployee(context, empId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showEmployeeDialog(context),
      ),
    );
  }
}
