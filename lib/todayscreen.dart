import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

class TodayScreen extends StatefulWidget {

  final Map<String, dynamic> employee; // you can use your Employee model later

  const TodayScreen({Key? key, required this.employee}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  @override
  void initState() {
    super.initState();
    _getRecord();
  }
  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("employees")
          .where('name', isEqualTo: widget.employee['name'])
          .get();

      if (snap.docs.isEmpty) {
        print("No employee found for ${widget.employee['name']}");
        return;
      }

      String todayId = DateFormat('dd MMMM yyyy').format(DateTime.now());
      print("Looking for record: $todayId");

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("employees")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(todayId)
          .get();

      if (!snap2.exists) {
        print("No record found for today");
        return;
      }

      setState(() {
        checkIn = snap2['checkIn'] ?? "--/--";
        checkOut = snap2['checkOut'] ?? "--/--";
      });

    } catch (e) {
      print("Error in _getRecord(): $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    String employeeName = widget.employee['name'] ?? "Employee";
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "Welcome",
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "NexaRegular",
                  fontSize: screenWidth / 20,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                employeeName,
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "Today's Status",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 32),
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2)
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check In",
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            fontSize: screenWidth/20,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          checkIn,
                          style: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: screenWidth/18,
                          ),
                        ),
                      ],
                    ),
                  )
                  ),
                  Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Check Out",
                              style: TextStyle(
                                fontFamily: "NexaRegular",
                                fontSize: screenWidth/20,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              checkOut,
                              style: TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: screenWidth/18,
                              ),
                            ),
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),

            Container(
              alignment: Alignment.centerLeft,
              child: RichText(text: TextSpan(
                text: DateTime.now().day.toString(),
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: screenWidth/18,
                  fontFamily: "NexaBold",
                ),
                children: [
                  TextSpan(
                    text: DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "NexaBold",
                      fontSize: screenWidth/20,
                    )

                  )
                ]
              ))
            ),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, asyncSnapshot) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('hh:mm:ss a').format(DateTime.now()),
                    style: TextStyle(
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth/20,
                      color: Colors.black54,
                    ),
                  ),
                );
              }
            ),
            checkOut == "--/--" ? Container(
              margin: const EdgeInsets.only(top: 24),
              child: Builder(
                  builder: (context){
                    final GlobalKey<SlideActionState> key = GlobalKey();

                    return SlideAction(
                      text: checkIn == "--/--" ? "Slide to Check In" : "Slide to Check Out",
                      textStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth/20,
                        fontFamily: "NexaRegular",
                      ),
                      outerColor: Colors.white,
                      innerColor: Colors.red,
                      key: key,
                      onSubmit: () async {
                        Timer(Duration(seconds: 1), (){
                          key.currentState!.reset();
                        });
                        QuerySnapshot snap = await FirebaseFirestore.instance
                            .collection("employees")
                            .where('name', isEqualTo: widget.employee['name']) // 🔑 match by employeeId
                            .get();

                        DocumentSnapshot snap2 = await FirebaseFirestore.instance
                            .collection("employees")
                            .doc(snap.docs[0].id)
                            .collection("Record")
                            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                            .get();

                        try{
                          String checkIn = snap2['checkIn'];
                          setState(() {
                            checkOut = DateFormat('hh : mm').format(DateTime.now());
                          });
                          await FirebaseFirestore.instance
                              .collection("employees")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                              .update({
                            'date' : Timestamp.now(),
                            'checkIn' : checkIn,
                            'checkOut' : DateFormat('hh : mm').format(DateTime.now())
                              });
                        } catch(e){
                          setState(() {
                            checkIn = DateFormat('hh : mm').format(DateTime.now());
                          });
                          await FirebaseFirestore.instance
                              .collection("employees")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                              .set({
                            'date' : Timestamp.now(),
                            'checkIn' : DateFormat('hh : mm').format(DateTime.now())
                          });
                        }
                      },
                    );
                  },
              ),
            ) : Container(
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                  "You have completed this day!",
                style: TextStyle(
                  fontFamily: "NexaRegular",
                  fontSize: screenWidth/20,
                  color: Colors.black54,
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
