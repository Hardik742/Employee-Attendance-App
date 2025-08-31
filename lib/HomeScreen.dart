import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeeapp/ProfileScreen.dart';
import 'package:employeeapp/calendarscreen.dart';
import 'package:employeeapp/todayscreen.dart';
import 'package:employeeapp/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> employee;   // ✅ use Map instead of Employee

  const HomeScreen({Key? key, required this.employee}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 1;
  double screenHeight = 0;
  double screenWidth = 0;
  String? docId;
  String? employeeId;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    getId();
  }

  void getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("employees")
        .where('name', isEqualTo: widget.employee['name'])
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        User.id = snap.docs[0].id;  // <- Firestore document ID
      });
    } else {
      print("No employee found");
    }
  }



  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          new CalendarScreen(),
          new TodayScreen(employee: widget.employee),
          new ProfileScreen(employee: widget.employee),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            )
          ]
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i= 0; i< navigationIcons.length; i++)...<Expanded>{
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = i;
                        });
                      },
                      child: Container(
                        height: screenHeight,
                        width: screenWidth,
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  navigationIcons[i],
                                color: currentIndex == i ? Colors.red : Colors.black54,
                                size: currentIndex == i ? 30 : 26,
                              ),
                              currentIndex == i ? Container(
                                margin: EdgeInsets.only(top: 6),
                                height: 3,
                                width: 24,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                                  color: Colors.red
                                ),
                              ) : const SizedBox(),
                            ],
                          ),

                        ),
                      ),
                    )
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
