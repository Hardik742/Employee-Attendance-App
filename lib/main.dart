import 'package:employeeapp/OnboardingPage.dart';
import 'package:employeeapp/RegisterScreen.dart';
import 'package:employeeapp/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome')?? false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const SplashScreen(), // First Screen
      localizationsDelegates: const[
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}
