import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim/features/main_layout/presentation/screens/main_screen.dart';
import 'package:muslim/features/onboarding/presentation/screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuranLibrary.init();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'), // Set global locale to Arabic
      fallbackLocale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.cairoTextTheme(), // Use premium Arabic font
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Dark theme as per splash/onboarding
      ),
      home: hasSeenOnboarding ? MainScreen() : const OnboardingScreen(),
    );
  }
}
