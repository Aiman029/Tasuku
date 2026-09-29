import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/anime_theme.dart';
import '../widgets/sakura_particles.dart';
import '../widgets/anime_mascot.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  int _quoteIndex = 0;
  final List<String> _animeQuotes = [
    '“A journey of a thousand leagues begins with a single quest! 🌸”',
    '“Wake up to reality! Your tasks await, master. ⚔️”',
    '“Believe in the you that conquers all daily challenges! ✨”',
    '“Leveling up your productivity... Ganbatte! 🍙”',
  ];

  Timer? _quoteTimer;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _glowAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    _quoteTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _animeQuotes.length;
        });
      }
    });

    _navigateTimer = Timer(const Duration(milliseconds: 2800), () {
      _goToHome();
    });
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _quoteTimer?.cancel();
    _navigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GestureDetector(
        onTap: _goToHome, // Tap anywhere to skip
        child: SakuraPetalsOverlay(
          petalCount: 24,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1B172B),
                        Color(0xFF13101E),
                        Color(0xFF0F0B18),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF0F5),
                        Color(0xFFFAF4FF),
                        Color(0xFFFFF7F9),
                      ],
                    ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Skip button in top corner
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: TextButton.icon(
                        onPressed: _goToHome,
                        style: TextButton.styleFrom(
                          foregroundColor: AnimeColors.sakuraPink,
                          backgroundColor: AnimeColors.sakuraPink.withAlpha(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // Animated Glowing Anime Crest / Mascot
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ScaleTransition(
                            scale: _glowAnimation,
                            child: const AnimeLogoCrest(size: 130),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Title with Anime Japanese Script & Subtitle
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AnimeColors.sakuraPink.withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AnimeColors.sakuraPink.withAlpha(80),
                                      ),
                                    ),
                                    child: const Text(
                                      'タスク',
                                      style: TextStyle(
                                        color: AnimeColors.sakuraPink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        AnimeColors.mysticVioletGradient
                                            .createShader(bounds),
                                    child: const Text(
                                      'TASUKU',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ANIME QUEST & SCHEDULE PLANNER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3.0,
                                  color: isDark
                                      ? AnimeColors.textSubDark
                                      : AnimeColors.textSubLight,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Animated Quote Carousel
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.25),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _animeQuotes[_quoteIndex],
                              key: ValueKey<int>(_quoteIndex),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AnimeColors.sakuraLight.withAlpha(200)
                                    : const Color(0xFF6B5875),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sleek Glowing Progress Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 6,
                              child: LinearProgressIndicator(
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : AnimeColors.sakuraPink.withAlpha(30),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AnimeColors.sakuraPink,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          '召喚中 • Summoning daily missions...',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
