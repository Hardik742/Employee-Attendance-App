import 'package:employeeapp/OnboardingPage.dart';
import 'package:flutter/material.dart';


import 'package:shared_preferences/shared_preferences.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () async {



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboardingpage()),
      );

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset(
              "assets/emp.gif",
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
