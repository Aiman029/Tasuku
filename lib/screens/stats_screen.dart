import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../theme/anime_theme.dart';
import '../widgets/sakura_particles.dart';
import '../widgets/anime_mascot.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _quoteIndex = 0;

  final List<Map<String, String>> _quotes = [
    {
      'quote': '“If you don’t take risks, you can’t create a future.”',
      'author': 'Monkey D. Luffy',
    },
    {
      'quote': '“Hard work is worthless for those that don’t believe in themselves.”',
      'author': 'Naruto Uzumaki',
    },
    {
      'quote': '“No matter how deep the night, it always turns to day.”',
      'author': 'Brook',
    },
    {
      'quote': '“Set your heart ablaze! Go beyond your limits!”',
      'author': 'Kyojuro Rengoku',
    },
    {
      'quote': '“It’s not whether you fall down, it’s whether you get back up.”',
      'author': 'All Might',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextQuote() {
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % _quotes.length;
    });
  }

  void _showBadgeDialog(
    BuildContext context, {
    required String emoji,
    required String title,
    required String desc,
    required bool unlocked,
    required String requirement,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: unlocked ? AnimeColors.starlightGold : Colors.white24,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (unlocked ? AnimeColors.sakuraPink : Colors.black)
                    .withAlpha(isDark ? 80 : 40),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: unlocked ? AnimeColors.sakuraGradient : null,
                  color: unlocked
                      ? null
                      : (isDark ? Colors.white10 : Colors.black12),
                  border: Border.all(
                    color: unlocked ? AnimeColors.starlightGold : Colors.grey,
                    width: 2,
                  ),
                  boxShadow: unlocked
                      ? [
                          BoxShadow(
                            color: AnimeColors.sakuraPink.withAlpha(120),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 38,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: unlocked
                      ? AnimeColors.starlightGold.withAlpha(40)
                      : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unlocked ? '✨ BADGE UNLOCKED' : '🔒 LOCKED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: unlocked
                        ? AnimeColors.starlightGold
                        : (isDark ? Colors.white54 : Colors.black54),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark
                      ? AnimeColors.textSubDark
                      : AnimeColors.textSubLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Requirement: $requirement',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AnimeColors.sakuraPink,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnimeColors.sakuraPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                ),
                child: const Text('Awesome! ✨',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.allTasks;
    final completedTasks = allTasks.where((t) => t.isDone).toList();
    final completedCount = completedTasks.length;
    final totalCount = allTasks.length;
    final rate = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate RPG EXP:
    // S-Rank = 100 EXP, A-Rank = 50 EXP, B-Rank = 25 EXP
    int totalExp = 0;
    int sRankCompleted = 0;
    int aRankCompleted = 0;
    int bRankCompleted = 0;

    for (var task in completedTasks) {
      final p = task.priority.toLowerCase();
      if (p == 'high' || p == 's') {
        totalExp += 100;
        sRankCompleted++;
      } else if (p == 'medium' || p == 'a') {
        totalExp += 50;
        aRankCompleted++;
      } else {
        totalExp += 25;
        bRankCompleted++;
      }
    }

    // Level formula: 150 EXP per level
    final userLevel = (totalExp ~/ 150) + 1;
    final currentLevelExp = totalExp % 150;
    final levelProgress = currentLevelExp / 150.0;

    String rankTitle = 'Academy Trainee 🌸';
    if (userLevel >= 7) {
      rankTitle = 'S-Rank Grandmaster 👑';
    } else if (userLevel >= 5) {
      rankTitle = 'Hashira Champion 🔥';
    } else if (userLevel >= 3) {
      rankTitle = 'Special Jonin ⚡';
    } else if (userLevel >= 2) {
      rankTitle = 'Guild Hunter 🗡️';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ハンター記録',
              style: TextStyle(
                fontSize: 11,
                color: AnimeColors.sakuraPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Hunter Guild Records 📊',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withAlpha(12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AnimeColors.sakuraGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AnimeColors.sakuraPink.withAlpha(90),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor:
                  isDark ? Colors.white60 : AnimeColors.textSubLight,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⚔️', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 6),
                      Text('Guild Status'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📈', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 6),
                      Text('Weekly Analytics'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SakuraPetalsOverlay(
        petalCount: 14,
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: Guild Status & RPG Attributes
            _buildGuildStatusTab(
              context,
              userLevel: userLevel,
              rankTitle: rankTitle,
              totalExp: totalExp,
              currentLevelExp: currentLevelExp,
              levelProgress: levelProgress,
              completedCount: completedCount,
              totalCount: totalCount,
              rate: rate,
              sRankCount: sRankCompleted,
              aRankCount: aRankCompleted,
              bRankCount: bRankCompleted,
              isDark: isDark,
              allTasks: allTasks,
              completedTasks: completedTasks,
            ),

            // TAB 2: Weekly Activity & Category Breakdown
            _buildWeeklyAnalyticsTab(
              context,
              allTasks: allTasks,
              completedTasks: completedTasks,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: GUILD STATUS & RPG ATTRIBUTES
  // ==========================================
  Widget _buildGuildStatusTab(
    BuildContext context, {
    required int userLevel,
    required String rankTitle,
    required int totalExp,
    required int currentLevelExp,
    required double levelProgress,
    required int completedCount,
    required int totalCount,
    required double rate,
    required int sRankCount,
    required int aRankCount,
    required int bRankCount,
    required bool isDark,
    required List<TaskModel> allTasks,
    required List<TaskModel> completedTasks,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. Adventurer Character Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF281E3B), Color(0xFF1B1328)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFFEEF3), Color(0xFFF4EBFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 80 : 50),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AnimeColors.sakuraPink.withAlpha(isDark ? 30 : 20),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const AnimeChibiMascot(size: 82, mood: 'happy'),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: AnimeColors.sakuraGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'LEVEL $userLevel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AnimeColors.starlightGold.withAlpha(35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥',
                                      style: TextStyle(fontSize: 11)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$totalExp EXP',
                                    style: const TextStyle(
                                      color: AnimeColors.starlightGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rankTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount of $totalCount Quests Cleared',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AnimeColors.textSubDark
                                : AnimeColors.textSubLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Level EXP Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Next Rank Progress',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AnimeColors.textSubDark
                              : AnimeColors.textSubLight,
                        ),
                      ),
                      Text(
                        '$currentLevelExp / 150 EXP',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AnimeColors.sakuraPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 9,
                      child: LinearProgressIndicator(
                        value: levelProgress.clamp(0.0, 1.0),
                        backgroundColor: isDark
                            ? Colors.white10
                            : AnimeColors.sakuraPink.withAlpha(25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AnimeColors.sakuraPink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Glowing Completion Rate Card with Donut Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Quest Success',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AnimeColors.sakuraPink.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(rate * 100).toInt()}% RATE',
                      style: const TextStyle(
                        color: AnimeColors.sakuraPink,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Donut Chart
              SizedBox(
                height: 190,
                child: totalCount == 0
                    ? Center(
                        child: Text(
                          'No quests recorded yet!\nSummon your first quest to begin ✨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AnimeColors.textSubDark
                                : AnimeColors.textSubLight,
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 56,
                              sections: [
                                PieChartSectionData(
                                  value: completedCount > 0
                                      ? completedCount.toDouble()
                                      : 0.001,
                                  title:
                                      completedCount > 0 ? '$completedCount' : '',
                                  color: AnimeColors.sakuraPink,
                                  radius: 46,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: (totalCount - completedCount) > 0
                                      ? (totalCount - completedCount).toDouble()
                                      : 0.001,
                                  title: (totalCount - completedCount) > 0
                                      ? '${totalCount - completedCount}'
                                      : '',
                                  color: AnimeColors.animeViolet,
                                  radius: 46,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(rate * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AnimeColors.sakuraPink,
                                ),
                              ),
                              Text(
                                'CLEARED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 18),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _legendItem(AnimeColors.sakuraPink, 'Cleared Quests',
                      completedCount, isDark),
                  _legendItem(AnimeColors.animeViolet, 'Active Missions',
                      totalCount - completedCount, isDark),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Anime RPG Combat Attributes Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('⚡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Hunter Combat Attributes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Discipline (Completion Rate)
              _buildAttributeBar(
                title: 'Discipline (律)',
                icon: '🛡️',
                value: rate,
                label: '${(rate * 100).toInt()}%',
                rank: rate >= 0.8
                    ? 'S'
                    : rate >= 0.5
                        ? 'A'
                        : 'B',
                color: AnimeColors.sakuraPink,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Power (High difficulty S-Ranks)
              _buildAttributeBar(
                title: 'Power (力)',
                icon: '🔥',
                value: (sRankCount / (totalCount > 0 ? totalCount : 1))
                    .clamp(0.0, 1.0),
                label: '$sRankCount S-Rank Cleared',
                rank: sRankCount >= 3
                    ? 'S'
                    : sRankCount >= 1
                        ? 'A'
                        : 'B',
                color: AnimeColors.rankS,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Focus / Wisdom (Study & Work tasks)
              _buildAttributeBar(
                title: 'Wisdom & Focus (智)',
                icon: '📚',
                value: ((completedTasks
                                .where((t) =>
                                    t.category == 'Study' ||
                                    t.category == 'Work')
                                .length) /
                            (completedCount > 0 ? completedCount : 1))
                    .clamp(0.0, 1.0),
                label:
                    '${completedTasks.where((t) => t.category == 'Study' || t.category == 'Work').length} Missions',
                rank: completedCount >= 5
                    ? 'S'
                    : completedCount >= 2
                        ? 'A'
                        : 'B',
                color: AnimeColors.animeViolet,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Stamina (Total quests completed)
              _buildAttributeBar(
                title: 'Stamina (気)',
                icon: '⚔️',
                value: (completedCount / 15.0).clamp(0.0, 1.0),
                label: '$completedCount Tasks Done',
                rank: completedCount >= 10
                    ? 'S'
                    : completedCount >= 4
                        ? 'A'
                        : 'B',
                color: AnimeColors.electricCyan,
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. Hunter Badges Showcase (Interactive with dialogs)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hunter Badges & Trophies 🏆',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Tap to inspect',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Badges Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _interactiveBadge(
                    context,
                    emoji: '🗡️',
                    title: 'First Blood',
                    desc: 'You cleared your very first mission and took your first step as a hunter.',
                    requirement: 'Complete 1 quest',
                    unlocked: completedCount >= 1,
                    isDark: isDark,
                  ),
                  _interactiveBadge(
                    context,
                    emoji: '🔥',
                    title: 'S-Rank Slayer',
                    desc: 'Conquered a high-difficulty S-Rank quest with unwavering courage.',
                    requirement: 'Complete 1 S-Rank quest',
                    unlocked: sRankCount >= 1,
                    isDark: isDark,
                  ),
                  _interactiveBadge(
                    context,
                    emoji: '⚡',
                    title: 'Quest Master',
                    desc: 'Proved your reliability by clearing 5 or more quests.',
                    requirement: 'Complete 5 quests',
                    unlocked: completedCount >= 5,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _interactiveBadge(
                    context,
                    emoji: '📚',
                    title: 'Grand Scholar',
                    desc: 'Dedicated your focus to mastering study and training missions.',
                    requirement: 'Complete 3 Academy tasks',
                    unlocked: completedTasks
                            .where((t) => t.category == 'Study')
                            .length >=
                        3,
                    isDark: isDark,
                  ),
                  _interactiveBadge(
                    context,
                    emoji: '🌸',
                    title: 'Sakura Harmony',
                    desc: 'Achieved flawless 100% completion rate with multiple quests.',
                    requirement: '100% rate with >= 3 quests',
                    unlocked: rate == 1.0 && totalCount >= 3,
                    isDark: isDark,
                  ),
                  _interactiveBadge(
                    context,
                    emoji: '👑',
                    title: 'Legendary Hero',
                    desc: 'Reached the summit of the guild. A true Hashira of productivity!',
                    requirement: 'Complete 15 quests or reach Lvl 5',
                    unlocked: completedCount >= 15 || userLevel >= 5,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 5. Anime Quote of the Day Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF251A33), Color(0xFF1D1426)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFFF0F5), Color(0xFFFAF3FF)],
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AnimeColors.animeViolet.withAlpha(isDark ? 60 : 40),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('🌸', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 6),
                      Text(
                        'Anime Wisdom of the Day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _nextQuote,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Text('Roll 🎲',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AnimeColors.sakuraPink)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _quotes[_quoteIndex]['quote']!,
                  key: ValueKey<int>(_quoteIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: isDark
                        ? Colors.white.withAlpha(230)
                        : const Color(0xFF4A3E56),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '— ${_quotes[_quoteIndex]['author']}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AnimeColors.sakuraPink,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ==========================================
  // TAB 2: WEEKLY ANALYTICS & BREAKDOWN
  // ==========================================
  Widget _buildWeeklyAnalyticsTab(
    BuildContext context, {
    required List<TaskModel> allTasks,
    required List<TaskModel> completedTasks,
    required bool isDark,
  }) {
    // Compute weekday completion counts (Mon = 1, Sun = 7)
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<int, int> dayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (var task in completedTasks) {
      final day = task.dueDate.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    // Difficulty breakdown
    int sRank = 0;
    int aRank = 0;
    int bRank = 0;
    for (var t in allTasks) {
      final p = t.priority.toLowerCase();
      if (p == 'high' || p == 's') {
        sRank++;
      } else if (p == 'medium' || p == 'a') {
        aRank++;
      } else {
        bRank++;
      }
    }

    // Category counts
    final categories = ['General', 'Study', 'Work', 'Personal', 'Gaming'];
    final categoryIcons = {'General': '🌸', 'Study': '📚', 'Work': '💼', 'Personal': '🍜', 'Gaming': '🎮'};

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. Weekly Activity Bar Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '7-Day Quest Activity 📊',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AnimeColors.starlightGold.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AnimeColors.starlightGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Bar Chart
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (dayCounts.values.fold(0, (a, b) => a > b ? a : b) + 2)
                        .toDouble(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AnimeColors.sakuraPink,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} Quests',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 22,
                          getTitlesWidget: (val, meta) {
                            if (val % 1 == 0) {
                              return Text(
                                '${val.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
                            if (idx >= 0 && idx < weekDays.length) {
                              final isToday = (idx + 1) == now.weekday;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  weekDays[idx],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isToday
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    color: isToday
                                        ? AnimeColors.sakuraPink
                                        : (isDark
                                            ? Colors.white54
                                            : Colors.black54),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? Colors.white10 : Colors.black12,
                        strokeWidth: 0.8,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) {
                      final count = dayCounts[i + 1] ?? 0;
                      final isToday = (i + 1) == now.weekday;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            gradient: isToday
                                ? AnimeColors.sakuraGradient
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF845EC2),
                                      Color(0xFFB39CD0),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                            width: 14,
                            borderRadius: BorderRadius.circular(6),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: (dayCounts.values
                                          .fold(0, (a, b) => a > b ? a : b) +
                                      2)
                                  .toDouble(),
                              color: isDark ? Colors.white10 : Colors.black.withAlpha(8),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Quest Difficulty (Rank) Distribution
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Difficulty Distribution 🔥',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _difficultyCard('S-Rank 🔥', sRank, AnimeColors.rankS, isDark),
                  const SizedBox(width: 10),
                  _difficultyCard('A-Rank ⚡', aRank, AnimeColors.rankA, isDark),
                  const SizedBox(width: 10),
                  _difficultyCard('B-Rank 🍃', bRank, AnimeColors.rankB, isDark),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Category Breakdown with Progress
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AnimeColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AnimeColors.sakuraPink.withAlpha(isDark ? 50 : 35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Mastery 🏷️',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...categories.map((cat) {
                final catTasks = allTasks.where((t) => t.category == cat);
                final catDone = catTasks.where((t) => t.isDone).length;
                final catTotal = catTasks.length;
                final catRate = catTotal > 0 ? (catDone / catTotal) : 0.0;
                final icon = categoryIcons[cat] ?? '🌸';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(icon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                cat,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$catDone / $catTotal Cleared (${(catRate * 100).toInt()}%)',
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
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: catRate,
                          minHeight: 7,
                          backgroundColor: isDark
                              ? Colors.white10
                              : AnimeColors.sakuraPink.withAlpha(20),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AnimeColors.sakuraPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildAttributeBar({
    required String title,
    required String icon,
    required double value,
    required String label,
    required String rank,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    '$rank-Tier',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: isDark ? Colors.white10 : color.withAlpha(25),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _interactiveBadge(
    BuildContext context, {
    required String emoji,
    required String title,
    required String desc,
    required String requirement,
    required bool unlocked,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _showBadgeDialog(
        context,
        emoji: emoji,
        title: title,
        desc: desc,
        unlocked: unlocked,
        requirement: requirement,
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked ? AnimeColors.sakuraGradient : null,
              color: unlocked
                  ? null
                  : (isDark ? Colors.white10 : Colors.black.withAlpha(12)),
              border: Border.all(
                color:
                    unlocked ? AnimeColors.starlightGold : Colors.transparent,
                width: 1.8,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: AnimeColors.sakuraPink.withAlpha(90),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 75,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: unlocked
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _difficultyCard(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 45 : 30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(100), width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, int count, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(100),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}