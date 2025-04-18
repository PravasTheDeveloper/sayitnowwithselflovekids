import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/subscription_card.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E8D0), // Cream/beige background color from the website
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
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      _buildSubscriptionSection(context),
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
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white),
                  textStyle: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B4513), // Brown color similar to "CALL NOW" button
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            child: Image.network(
              'https://public.readdy.ai/ai/img_res/c20f585f79421421b3c693e45a6a6cf3.jpg',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nurturing Self-Love in Every Child',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513), // Brown color matching the website
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Join us in building emotional intelligence and confidence through play and learning',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: AppTheme.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Plan',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513), // Brown color matching the website
            ),
          ),
          const SizedBox(height: 16),
          SubscriptionCard(
            title: 'Monthly Growth',
            price: '\$11.99',
            billingPeriod: 'Billed monthly',
            features: [
              'Access to emotional learning activities',
              'Digital self-love journal',
              'Monthly emotional wellness resources',
            ],
            isHighlighted: false,
            onTap: () => _selectPlan(context, 'monthly'),
          ),
          const SizedBox(height: 16),
          SubscriptionCard(
            title: 'Yearly Journey',
            price: '\$99.99',
            billingPeriod: 'Billed annually',
            features: [
              'All monthly growth features',
              '1-on-1 parent consultation',
              'Exclusive workshops with Gloria',
              'Printed self-love activity book',
            ],
            isHighlighted: true,
            discount: '30%',
            onTap: () => _selectPlan(context, 'yearly'),
          ),
        ],
      ),
    );
  }

  void _selectPlan(BuildContext context, String plan) {
    // Check if logged in (for a real app, use a proper auth system)
    // For demo, we'll just navigate to login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please login to subscribe to the $plan plan',
          style: GoogleFonts.roboto(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(context, '/login');
  }
}