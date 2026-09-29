import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/anime_theme.dart';
import '../widgets/anime_mascot.dart';
import '../widgets/sakura_particles.dart';

enum DungeonMode {
  noviceFocus('Novice Quest 🥋', '25 Min Focus', 25 * 60, AnimeColors.sakuraPink),
  deepTraining('Hashira Focus ⚡', '50 Min Deep Work', 50 * 60, AnimeColors.animeViolet),
  chakraRest('Chakra Rest 🍵', '5 Min Short Break', 5 * 60, AnimeColors.electricCyan),
  sakuraRespite('Sakura Respite 🌸', '15 Min Long Rest', 15 * 60, AnimeColors.starlightGold);

  final String title;
  final String description;
  final int totalSeconds;
  final Color themeColor;

  const DungeonMode(this.title, this.description, this.totalSeconds, this.themeColor);
}

class FocusDungeonScreen extends StatefulWidget {
  const FocusDungeonScreen({super.key});

  @override
  State<FocusDungeonScreen> createState() => _FocusDungeonScreenState();
}

class _FocusDungeonScreenState extends State<FocusDungeonScreen>
    with SingleTickerProviderStateMixin {
  DungeonMode _selectedMode = DungeonMode.noviceFocus;
  late int _remainingSeconds;
  bool _isRunning = false;
  Timer? _timer;

  int _completedSessionsToday = 0;
  int _totalFocusMinutesToday = 0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMode.totalSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectMode(DungeonMode mode) {
    if (_isRunning) {
      _showSwitchWarningDialog(mode);
      return;
    }
    setState(() {
      _selectedMode = mode;
      _remainingSeconds = mode.totalSeconds;
    });
  }

  void _showSwitchWarningDialog(DungeonMode newMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('⚠️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Abandon Chamber?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Your active training session is currently underway. Switching training modes will reset the chamber timer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Training'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AnimeColors.flameCrimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _resetTimer();
              setState(() {
                _selectedMode = newMode;
                _remainingSeconds = newMode.totalSeconds;
              });
            },
            child: const Text('Switch & Reset'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
    });

    context.read<NavigationProvider>().setDungeonTimerRunning(true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _onSessionComplete();
      }
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    context.read<NavigationProvider>().setDungeonTimerRunning(false);
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMode.totalSeconds;
    });
    context.read<NavigationProvider>().setDungeonTimerRunning(false);
  }

  void _onSessionComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMode.totalSeconds;
      if (_selectedMode == DungeonMode.noviceFocus ||
          _selectedMode == DungeonMode.deepTraining) {
        _completedSessionsToday++;
        _totalFocusMinutesToday += (_selectedMode.totalSeconds ~/ 60);
      }
    });

    context.read<NavigationProvider>().setDungeonTimerRunning(false);
    HapticFeedback.heavyImpact();

    _showCelebrationDialog();
  }

  void _showCelebrationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AnimeColors.starlightGold,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AnimeColors.starlightGold.withAlpha(100),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimeChibiMascot(
                size: 76,
                mood: 'quest',
              ),
              const SizedBox(height: 16),
              const Text(
                'DUNGEON CONQUERED! 🏆',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AnimeColors.starlightGold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Splendid focus, master! You completed your ${_selectedMode.title} session with unbreakable discipline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AnimeColors.textSubDark : AnimeColors.textSubLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AnimeColors.starlightGold.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AnimeColors.starlightGold.withAlpha(80)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      '+50 Dungeon Mastery EXP 🗡️',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: AnimeColors.starlightGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnimeColors.sakuraPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Accept Glory & Return 🌸',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getMascotQuote() {
    if (_isRunning) {
      if (_selectedMode == DungeonMode.chakraRest ||
          _selectedMode == DungeonMode.sakuraRespite) {
        return 'Rest is part of the warrior’s journey. Breathe deeply... 🍵';
      }
      return 'Focus your chakra! Banish all distractions! ⚔️';
    } else {
      if (_remainingSeconds < _selectedMode.totalSeconds) {
        return 'Session paused. Ready to jump back into the fray? 🛡️';
      }
      return 'Step into the hyperbolic chamber when you are ready, adventurer! ✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = 1.0 - (_remainingSeconds / _selectedMode.totalSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '修行ダンジョン',
              style: TextStyle(
                fontSize: 11,
                color: AnimeColors.sakuraPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Focus Dungeon 🔥',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: SakuraPetalsOverlay(
        petalCount: 16,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Column(
            children: [
              // Mode Selector Tabs
              _buildModeSelector(isDark),

              const SizedBox(height: 24),

              // Circular Countdown Gauge
              _buildTimerGauge(progress, isDark),

              const SizedBox(height: 24),

              // Interactive Action Controls
              _buildTimerControls(isDark),

              const SizedBox(height: 24),

              // Anime Mascot Speech Bubble
              _buildMascotCard(isDark),

              const SizedBox(height: 20),

              // Dungeon Daily Performance Metrics
              _buildPerformanceCard(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: DungeonMode.values.map((mode) {
          final isSelected = _selectedMode == mode;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                mode.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              selected: isSelected,
              selectedColor: mode.themeColor,
              backgroundColor: isDark ? AnimeColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? mode.themeColor
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 1.2,
                ),
              ),
              onSelected: (_) => _selectMode(mode),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimerGauge(double progress, bool isDark) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRunning ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Aura Ring
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AnimeColors.cardDark : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _selectedMode.themeColor.withAlpha(isDark ? 50 : 35),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // Animated Gauge Painter
              CustomPaint(
                size: const Size(230, 230),
                painter: _DungeonGaugePainter(
                  progress: progress,
                  accentColor: _selectedMode.themeColor,
                  trackColor: isDark ? Colors.white10 : Colors.black12,
                ),
              ),

              // Center Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _selectedMode.themeColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedMode.themeColor.withAlpha(80),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _isRunning ? '⚔️ IN FOCUS' : 'CHAMBER IDLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _selectedMode.themeColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white : AnimeColors.textMainLight,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedMode.description,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AnimeColors.textSubDark
                          : AnimeColors.textSubLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset Button
        IconButton.filledTonal(
          iconSize: 24,
          tooltip: 'Reset Chamber Timer',
          style: IconButton.styleFrom(
            backgroundColor: isDark ? Colors.white12 : Colors.black.withAlpha(15),
            foregroundColor: isDark ? Colors.white70 : Colors.black87,
            padding: const EdgeInsets.all(14),
            shape: const CircleBorder(),
          ),
          onPressed: _resetTimer,
          icon: const Icon(Icons.replay_rounded),
        ),

        const SizedBox(width: 20),

        // Start / Pause Big Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                _selectedMode.themeColor,
                Color.lerp(_selectedMode.themeColor, Colors.white, 0.25)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _selectedMode.themeColor.withAlpha(120),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _isRunning ? _pauseTimer : _startTimer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRunning ? 'Pause Focus' : 'Commence Quest',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Skip to end button
        IconButton.filledTonal(
          iconSize: 24,
          tooltip: 'Complete / Skip Session',
          style: IconButton.styleFrom(
            backgroundColor: isDark ? Colors.white12 : Colors.black.withAlpha(15),
            foregroundColor: isDark ? Colors.white70 : Colors.black87,
            padding: const EdgeInsets.all(14),
            shape: const CircleBorder(),
          ),
          onPressed: () {
            if (_remainingSeconds > 0) {
              _onSessionComplete();
            }
          },
          icon: const Icon(Icons.fast_forward_rounded),
        ),
      ],
    );
  }

  Widget _buildMascotCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AnimeColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AnimeColors.sakuraPink.withAlpha(isDark ? 45 : 30),
        ),
        boxShadow: [
          BoxShadow(
            color: AnimeColors.sakuraPink.withAlpha(isDark ? 15 : 10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimeChibiMascot(
            size: 56,
            mood: _isRunning ? 'quest' : 'happy',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🌸', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(
                      'Tasu-chan Mentorship',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AnimeColors.sakuraPink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _getMascotQuote(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: isDark ? Colors.white70 : AnimeColors.textMainLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AnimeColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AnimeColors.animeViolet.withAlpha(isDark ? 50 : 30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'Today’s Dungeon Conquests',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _metricPill(
                icon: Icons.check_circle_outline_rounded,
                color: AnimeColors.electricCyan,
                label: 'Sessions',
                value: '$_completedSessionsToday',
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _metricPill(
                icon: Icons.timer_outlined,
                color: AnimeColors.starlightGold,
                label: 'Focus Time',
                value: '$_totalFocusMinutesToday m',
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _metricPill(
                icon: Icons.local_fire_department_rounded,
                color: AnimeColors.flameCrimson,
                label: 'EXP Gained',
                value: '+${_completedSessionsToday * 50}',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricPill({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DungeonGaugePainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color trackColor;

  _DungeonGaugePainter({
    required this.progress,
    required this.accentColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress Arc with Gradient
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    const startAngle = -math.pi / 2;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [accentColor.withAlpha(180), accentColor],
        startAngle: 0.0,
        endAngle: 2 * math.pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DungeonGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.trackColor != trackColor;
  }
}
