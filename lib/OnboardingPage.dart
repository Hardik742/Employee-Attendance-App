import 'package:employeeapp/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboardingpage extends StatefulWidget {
  const Onboardingpage({super.key});

  @override
  State<Onboardingpage> createState() => _OnboardingpageState();
}

class _OnboardingpageState extends State<Onboardingpage> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildPage({
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
  }) =>
      Container(
        color: color,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Image
                Image.asset(
                  urlImage,
                  fit: BoxFit.contain,
                  height: 250,
                ),
                const SizedBox(height: 50),

                // 🔹 Title
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Subtitle
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      padding: const EdgeInsets.only(bottom: 80),
      child: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() => isLastPage = index == 2);
        },
        children: [
          buildPage(
            color: Colors.green.shade100,
            urlImage: 'assets/image1.png',
            title: 'Quick Attendance',
            subtitle:
            'Mark your attendance in just one tap,\nno paperwork needed.',
          ),
          buildPage(
            color: Colors.green.shade100,
            urlImage: 'assets/attendance.png',
            title: 'Live Attendance Records',
            subtitle:
            'Track attendance history\nand stay updated in real-time.',
          ),
          buildPage(
            color: Colors.green.shade100,
            urlImage: 'assets/em3.png',
            title: 'Safe & Secure',
            subtitle:
            'Your attendance data is encrypted\nand safely stored.',
          ),
        ],
      ),
    ),

    // 🔹 Bottom Sheet
    bottomSheet: isLastPage
        ? Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      height: 90,
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('showHome', true);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            "Get Started",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    )
        : Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: const Text("SKIP"),
            onPressed: () => controller.jumpToPage(2),
          ),
          SmoothPageIndicator(
            controller: controller,
            count: 3,
            effect: WormEffect(
              dotHeight: 12,
              dotWidth: 12,
              activeDotColor: Colors.teal.shade700,
            ),
            onDotClicked: (index) => controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            ),
          ),
          TextButton(
            child: const Text("NEXT"),
            onPressed: () => controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    ),
  );
}
