import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeeapp/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String? docId;
  Color primary = const Color(0xffeef444c);

  String _month = DateFormat('MMMM').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "My Attendance",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 32),
                  child: Text(
                    _month,
                    style: TextStyle(
                      fontFamily: "NexaBold",
                      fontSize: screenWidth / 18,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 32),
                  child: GestureDetector(
                    onTap: () async {
                      final month = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2099),
                          builder: (context,  child) {
                            return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme : ColorScheme.light(
                                    primary: primary,
                                    secondary: primary,
                                    onSecondary: Colors.white,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor : primary
                                    ),
                                  ),
                                  textTheme: TextTheme(
                                    headlineLarge: TextStyle(
                                      fontFamily: "NexaBold",
                                    ),
                                  )
                                ),
                                child: child!);
                          }
                      );
                      if(month != null){
                        setState(() {
                          _month= DateFormat('MMMM').format(month);
                        });
                      }
                    },
                    child: Text(
                      "Pick a Month",
                      style: TextStyle(
                        fontFamily: "NexaBold",
                        fontSize: screenWidth / 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight / 1.45,
                child: StreamBuilder<QuerySnapshot> (
                  stream: FirebaseFirestore.instance
                      .collection("employees")
                      .doc(User.id)
                      .collection("Record")
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                    if (snapshot.hasData){
                      final snap = snapshot.data!.docs;
                      return ListView.builder(
                          itemCount: snap.length,
                          itemBuilder: (context , index) {
                            return DateFormat('MMMM').format(snap[index]['date'].toDate()) == _month
                                ? Container(
                              margin: EdgeInsets.only(top: index > 0 ? 12 : 0, right: 6, left: 6),
                              height: 150,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 🔹 Date
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primary,
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          DateFormat('EE\ndd')
                                              .format(snap[index]['date'].toDate()),
                                          style: TextStyle(
                                            fontFamily: "NexaRegular",
                                            fontSize: screenWidth / 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 🔹 Check In
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Check In",
                                          style: TextStyle(
                                            fontFamily: "NexaRegular",
                                            fontSize: screenWidth / 20,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          snap[index].data().toString().contains('checkIn')
                                              ? snap[index]['checkIn']
                                              : "Not Checked In",
                                          style: TextStyle(
                                            fontFamily: "NexaBold",
                                            fontSize: screenWidth / 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 🔹 Check Out
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Check Out",
                                          style: TextStyle(
                                            fontFamily: "NexaRegular",
                                            fontSize: screenWidth / 20,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          snap[index].data().toString().contains('checkOut')
                                              ? snap[index]['checkOut']
                                              : "Not Checked Out",
                                          style: TextStyle(
                                            fontFamily: "NexaBold",
                                            fontSize: screenWidth / 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : const SizedBox();

                          },
                      );
                    }
                    else{
                      return const SizedBox();
                    }
                  },
                ),
            ),
          ],
        ),
      )
    );
  }
}
