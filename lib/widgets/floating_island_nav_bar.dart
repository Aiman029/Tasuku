import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/task_provider.dart';
import '../theme/anime_theme.dart';

class FloatingIslandNavBar extends StatelessWidget {
  const FloatingIslandNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final pendingCount = taskProvider.pendingCount;
    final isTimerRunning = navProvider.isDungeonTimerRunning;

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, (bottomInset > 0 ? 4 : 12)),
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 35 : 25),
              blurRadius: 22,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 85 : 30),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B162B).withAlpha(225)
                    : Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: AnimeColors.sakuraPink.withAlpha(isDark ? 65 : 45),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  _NavBarItem(
                    index: 0,
                    icon: Icons.assignment_rounded,
                    outlineIcon: Icons.assignment_outlined,
                    label: 'Quests',
                    subLabel: 'クエスト',
                    isSelected: navProvider.currentIndex == 0,
                    badgeText: pendingCount > 0
                        ? (pendingCount > 9 ? '9+' : '$pendingCount')
                        : null,
                    badgeColor: AnimeColors.sakuraPink,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      navProvider.setIndex(0);
                    },
                  ),
                  _NavBarItem(
                    index: 1,
                    icon: Icons.calendar_month_rounded,
                    outlineIcon: Icons.calendar_month_outlined,
                    label: 'Calendar',
                    subLabel: 'カレンダー',
                    isSelected: navProvider.currentIndex == 1,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      navProvider.setIndex(1);
                    },
                  ),
                  _NavBarItem(
                    index: 2,
                    icon: Icons.local_fire_department_rounded,
                    outlineIcon: Icons.local_fire_department_outlined,
                    label: 'Dungeon',
                    subLabel: '修行',
                    isSelected: navProvider.currentIndex == 2,
                    hasPulseBadge: isTimerRunning,
                    badgeColor: AnimeColors.starlightGold,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      navProvider.setIndex(2);
                    },
                  ),
                  _NavBarItem(
                    index: 3,
                    icon: Icons.insights_rounded,
                    outlineIcon: Icons.insights_outlined,
                    label: 'Guild',
                    subLabel: '記録',
                    isSelected: navProvider.currentIndex == 3,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      navProvider.setIndex(3);
                    },
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

class _NavBarItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  final String subLabel;
  final bool isSelected;
  final String? badgeText;
  final bool hasPulseBadge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.icon,
    required this.outlineIcon,
    required this.label,
    required this.subLabel,
    required this.isSelected,
    this.badgeText,
    this.hasPulseBadge = false,
    this.badgeColor = AnimeColors.sakuraPink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? AnimeColors.sakuraPink.withAlpha(isDark ? 45 : 30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            border: isSelected
                ? Border.all(
                    color: AnimeColors.sakuraPink.withAlpha(isDark ? 90 : 60),
                    width: 1.2,
                  )
                : Border.all(color: Colors.transparent, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animated scale and badges
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: isSelected ? 1.0 : 0.9,
                      end: isSelected ? 1.15 : 0.95,
                    ),
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          isSelected ? icon : outlineIcon,
                          size: 22,
                          color: isSelected
                              ? AnimeColors.sakuraPink
                              : (isDark
                                  ? AnimeColors.textSubDark
                                  : AnimeColors.textSubLight),
                        ),
                      );
                    },
                  ),

                  // Numeric Badge (e.g. pending quests count)
                  if (badgeText != null)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: badgeColor.withAlpha(120),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),

                  // Pulsing Indicator (e.g. active timer)
                  if (hasPulseBadge)
                    Positioned(
                      top: -3,
                      right: -6,
                      child: _PulseDot(color: badgeColor),
                    ),
                ],
              ),
              const SizedBox(height: 3),

              // Animated Text & Micro Subtitle
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : AnimeColors.textMainLight)
                      : (isDark
                          ? AnimeColors.textSubDark.withAlpha(190)
                          : AnimeColors.textSubLight),
                  letterSpacing: 0.2,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Japanese anime micro-subtitle
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AnimeColors.sakuraPink.withAlpha(isDark ? 210 : 190),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;

  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.85 + (_controller.value * 0.4);
        final opacity = 0.5 + (_controller.value * 0.5);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: opacity),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: opacity),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
