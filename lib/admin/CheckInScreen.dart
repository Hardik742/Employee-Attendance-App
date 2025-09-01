import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchCheckInRecords() async {
    List<Map<String, dynamic>> records = [];

    // Get all employees
    QuerySnapshot employeesSnapshot =
    await FirebaseFirestore.instance.collection('employees').get();

    for (var emp in employeesSnapshot.docs) {
      String empId = emp.id;
      String empName = emp['name'] ?? 'Unknown';

      // Get check-in records for this employee
      QuerySnapshot recordSnapshot =
      await emp.reference.collection('Record').get();

      for (var rec in recordSnapshot.docs) {
        var data = rec.data() as Map<String, dynamic>;

        records.add({
          "employeeId": empId,
          "name": empName,
          "dateId": rec.id, // document ID = "01 September 2025"
          "checkIn": data["checkIn"], // string (ex: "11 : 45")
        });
      }
    }

    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Employee Check-In Records",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCheckInRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Check-In Records Found",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          var records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              var record = records[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.green.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.15),
                    child: const Icon(Icons.login, color: Colors.green),
                  ),
                  title: Text(
                    "${record['name']} (${record['employeeId']})",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📅 Date: ${record['dateId']}",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        Text(
                          "⏰ Check-In: ${record['checkIn']}",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
