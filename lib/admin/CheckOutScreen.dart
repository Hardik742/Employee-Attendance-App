import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchCheckOutRecords() async {
    List<Map<String, dynamic>> records = [];

    // Get all employees
    QuerySnapshot employeesSnapshot =
    await FirebaseFirestore.instance.collection('employees').get();

    for (var emp in employeesSnapshot.docs) {
      String empId = emp.id;
      String empName = emp['name'] ?? 'Unknown';

      // Get check-out records for this employee
      QuerySnapshot recordSnapshot =
      await emp.reference.collection('Record').get();

      for (var rec in recordSnapshot.docs) {
        var data = rec.data() as Map<String, dynamic>;

        records.add({
          "employeeId": empId,
          "name": empName,
          "dateId": rec.id, // ex: "01 September 2025"
          "checkOut": data["checkOut"], // string (ex: "18 : 20")
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
          "Employee Check-Out Records",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCheckOutRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Check-Out Records Found",
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
                shadowColor: Colors.redAccent.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                    child: const Icon(Icons.logout, color: Colors.red),
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
                          "⏰ Check-Out: ${record['checkOut'] ?? 'Not Available'}",
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
