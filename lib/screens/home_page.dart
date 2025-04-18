import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayitnowwithselflovekids/screens/read_books.dart';
import 'package:sayitnowwithselflovekids/screens/product_screen.dart';
import 'package:sayitnowwithselflovekids/screens/task_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_card.dart';
import 'game_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E8D0), // Cream/beige background color
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeMessage(context),
                      const SizedBox(height: 24),
                      _buildFounderSection(),
                      const SizedBox(height: 24),
                      _buildNavigationSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF9A826), // Amber/orange starting color
            Color(0xFFFF8C00), // Darker orange ending color
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo image
          Image.asset(
            'assets/images/icon.png', // Update this path to your actual logo image path
            height: 40, // Adjust height as needed
            fit: BoxFit.contain,
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  'G',
                  style: GoogleFonts.roboto(
                    color: Color(0xFF8B4513), // Brown color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('Profile', style: GoogleFonts.roboto()),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('Settings', style: GoogleFonts.roboto()),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout', style: GoogleFonts.roboto()),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red, // Orange color to match header
            Colors.red, // Brown color for consistency
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Your Journey!',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore activities and resources to nurture self-love and emotional intelligence.',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Get Started', style: GoogleFonts.roboto()),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/author.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gloria Warren',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B4513), // Brown color
                  ),
                ),
                Text(
                  'Founder & Author',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Color(0xFFF9A826), // Orange color
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'With 20 years of experience in social work and education, Gloria creates resources that help children understand and express their emotions.',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavCard(
          title: 'Play Games',
          description: 'Fun with feelings',
          iconData: Icons.favorite_border,
          backgroundColor: Colors.white,
          iconColor: Color(0xFFF9A826), // Orange color
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GameScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        NavCard(
          title: 'Read Books',
          description: 'Stories for you',
          iconData: Icons.book,
          backgroundColor: Colors.white,
          iconColor: Color(0xFF8B4513), // Brown color
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReadBooks()),
            );
          },
        ),
        const SizedBox(height: 16),
        NavCard(
          title: 'Visit Shop',
          description: 'For grown-ups',
          iconData: Icons.shopping_bag_outlined,
          backgroundColor: Colors.white,
          iconColor: Color(0xFFF9A826), // Orange color
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        NavCard(
          title: 'My Diary',
          description: 'Draw and write',
          iconData: Icons.edit_note,
          backgroundColor: Colors.white,
          iconColor: Color(0xFFF9A826), // Orange color
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskManagement()),
            );
          },
        ),
      ],
    );
  }
}