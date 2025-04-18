import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SelfLoveKidsApp());
}

class SelfLoveKidsApp extends StatelessWidget {
  const SelfLoveKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Say It Now Self Love Kids',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use Roboto as the default font family
        textTheme: GoogleFonts.robotoTextTheme(
          AppTheme.lightTheme.textTheme,
        ),
        // Keep your other theme settings from AppTheme.lightTheme
        primaryColor: AppTheme.lightTheme.primaryColor,
        colorScheme: AppTheme.lightTheme.colorScheme,
        scaffoldBackgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBarTheme: AppTheme.lightTheme.appBarTheme,
        buttonTheme: AppTheme.lightTheme.buttonTheme,
        elevatedButtonTheme: AppTheme.lightTheme.elevatedButtonTheme,
        outlinedButtonTheme: AppTheme.lightTheme.outlinedButtonTheme,
        inputDecorationTheme: AppTheme.lightTheme.inputDecorationTheme,
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}