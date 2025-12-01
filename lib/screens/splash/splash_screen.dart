import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeTitle;
  late final Animation<Offset> _slideTitle;
  late final Animation<double> _fadeTagline;
  late final Animation<double> _fadeLoader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Title: Fade In + Slide Up (starts at 20%, ends at 60%)
    _fadeTitle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _slideTitle = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    // Tagline: Fade In (starts at 40%, ends at 80%)
    _fadeTagline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );

    // Loader: Fade In (starts at 60%, ends at 100%)
    _fadeLoader = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Subtle Linear Gradient Background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F7FF), // Very light blue/white
              Color(0xFFE1EFFE), // Soft sky blue
              Color(0xFFD6E8FF), // Gentle blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle Background Bubbles/Circles for texture
            ..._buildBackgroundBubbles(),

            // Main Content
            SizedBox.expand(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo with Glow Effect
                    _buildAnimatedLogo(),

                    const SizedBox(height: 32),

                    // Animated Title
                    SlideTransition(
                      position: _slideTitle,
                      child: FadeTransition(
                        opacity: _fadeTitle,
                        child: Text(
                          'SkyNews',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A365D), // Deep blue
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Animated Tagline
                    FadeTransition(
                      opacity: _fadeTagline,
                      child: Text(
                        'Discover the World',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B), // Slate gray
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom Loading Indicator
                    FadeTransition(
                      opacity: _fadeLoader,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3B82F6), // Brand blue
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your experience...',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logo with soft glow/shadow effect
  Widget _buildAnimatedLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            blurRadius: 60,
            spreadRadius: 20,
          ),
          // Inner soft shadow
          BoxShadow(
            color: const Color(0xFF60A5FA).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Lottie.asset(
        'assets/lotties/splash_animation.json',
        width: 220,
        height: 220,
        fit: BoxFit.contain,
      ),
    );
  }

  // Subtle decorative background bubbles
  List<Widget> _buildBackgroundBubbles() {
    return [
      Positioned(
        top: -50,
        right: -30,
        child: _buildBubble(180, 0.04),
      ),
      Positioned(
        top: 120,
        left: -60,
        child: _buildBubble(140, 0.03),
      ),
      Positioned(
        bottom: 200,
        right: -40,
        child: _buildBubble(120, 0.05),
      ),
      Positioned(
        bottom: -30,
        left: 30,
        child: _buildBubble(100, 0.04),
      ),
      Positioned(
        top: 300,
        right: 50,
        child: _buildBubble(60, 0.06),
      ),
    ];
  }

  Widget _buildBubble(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF3B82F6).withOpacity(opacity),
      ),
    );
  }
}
