import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime selectedDate = DateTime.now();

  Future<Map<String, dynamic>> _fetchDailyReport(DateTime date) async {
    String formattedDate = DateFormat("dd MMMM yyyy").format(date);

    QuerySnapshot employeesSnapshot =
    await FirebaseFirestore.instance.collection('employees').get();

    int present = 0;
    int absent = 0;
    int late = 0;

    List<Map<String, dynamic>> details = [];

    for (var emp in employeesSnapshot.docs) {
      String empId = emp.id;
      String empName = emp['name'] ?? "Unknown";
      String department = emp['department'] ?? "General";

      DocumentSnapshot record = await FirebaseFirestore.instance
          .collection("employees")
          .doc(empId)
          .collection("Record")
          .doc(formattedDate)
          .get();

      if (record.exists) {
        var data = record.data() as Map<String, dynamic>;
        String checkIn = data["checkIn"] ?? "-";
        String checkOut = data["checkOut"] ?? "-";

        present++;

        try {
          DateTime checkInTime = DateFormat("HH : mm").parse(checkIn);
          if (checkInTime.hour > 9 || (checkInTime.hour == 9 && checkInTime.minute > 15)) {
            late++;
          }
        } catch (_) {}

        details.add({
          "name": empName,
          "department": department,
          "checkIn": checkIn,
          "checkOut": checkOut,
        });
      } else {
        absent++;
        details.add({
          "name": empName,
          "department": department,
          "checkIn": "-",
          "checkOut": "-",
        });
      }
    }

    return {
      "present": present,
      "absent": absent,
      "late": late,
      "details": details,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance Reports",
          style: GoogleFonts.robotoSlab(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Date Picker
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📅 ${DateFormat("dd MMM yyyy").format(selectedDate)}",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white, // <-- Set text color to white
                    textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: const Text("Change Date"),
                ),

              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchDailyReport(selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      "No report available",
                      style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                var report = snapshot.data!;
                var details = report["details"] as List;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // 🔹 Summary Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSummaryCard(
                            "✅ Present",
                            report["present"],
                            Colors.green,
                          ),
                          _buildSummaryCard(
                            "❌ Absent",
                            report["absent"],
                            Colors.red,
                          ),
                          _buildSummaryCard(
                            "⏰ Late",
                            report["late"],
                            Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Employee-wise details
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: details.length,
                        itemBuilder: (context, index) {
                          var emp = details[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading: const Icon(Icons.person, color: Colors.deepPurple),
                              title: Text(
                                emp["name"],
                                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "Dept: ${emp["department"]}",
                                style: GoogleFonts.lato(fontSize: 14),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "IN: ${emp["checkIn"]}",
                                    style: GoogleFonts.lato(fontSize: 13),
                                  ),
                                  Text(
                                    "OUT: ${emp["checkOut"]}",
                                    style: GoogleFonts.lato(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 110,
        height: 80,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$value",
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
