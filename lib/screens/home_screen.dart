import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/anime_theme.dart';
import '../widgets/task_tile.dart';
import '../widgets/sakura_particles.dart';
import '../widgets/anime_mascot.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sakuraPetalsEnabled = true;
  bool _isSearchExpanded = false;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getAnimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Ohayou! 🌅';
    } else if (hour >= 12 && hour < 18) {
      return 'Konnichiwa! 🌸';
    } else {
      return 'Konbanwa! 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedCount = taskProvider.completedCount;
    final totalCount = taskProvider.allTasks.length;
    final userLevel = (completedCount ~/ 3) + 1;
    final expInLevel = (completedCount % 3) / 3.0;

    return Scaffold(
      body: SakuraPetalsOverlay(
        isEnabled: _sakuraPetalsEnabled,
        petalCount: 20,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Anime Header
              _buildAnimeHeader(context, userLevel, expInLevel, completedCount,
                  totalCount, isDark, taskProvider),

              // Expandable Search & Quick Sort Panel
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                child: _isSearchExpanded
                    ? _buildSearchAndSortPanel(context, taskProvider, isDark)
                    : const SizedBox.shrink(),
              ),

              // Filter Chips
              _buildFilterChips(context, taskProvider, isDark),

              // Task List or Anime Empty State
              Expanded(
                child: tasks.isEmpty
                    ? _buildEmptyState(context, isDark, taskProvider)
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 90),
                        physics: const BouncingScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 250 + (index * 60).clamp(0, 500)),
                            curve: Curves.easeOutCubic,
                            builder: (context, val, child) {
                              return Opacity(
                                opacity: val,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - val) * 20),
                                  child: child,
                                ),
                              );
                            },
                            child: TaskTile(
                              task: task,
                              onToggle: () =>
                                  taskProvider.toggleTaskStatus(task.id),
                              onDelete: () => taskProvider.deleteTask(task.id),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(task: task),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAnimeFAB(context),
    );
  }

  Widget _buildAnimeHeader(BuildContext context, int level, double expProgress,
      int completed, int total, bool isDark, TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark
            ? AnimeColors.cardDark.withAlpha(220)
            : Colors.white.withAlpha(220),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AnimeColors.sakuraPink.withAlpha(isDark ? 20 : 15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row: Greeting & Action Buttons
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getAnimeGreeting(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AnimeColors.sakuraPink,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AnimeColors.starlightGold.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LVL $level',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AnimeColors.starlightGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Daily Quests ⚔️',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Search & Filter Toggle Button
              IconButton(
                tooltip: _isSearchExpanded
                    ? 'Hide Search & Sort'
                    : 'Search & Sort Quests',
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      _isSearchExpanded
                          ? Icons.tune_rounded
                          : Icons.search_rounded,
                      color: _isSearchExpanded ||
                              taskProvider.hasActiveSearchOrFilter
                          ? AnimeColors.sakuraPink
                          : (isDark ? Colors.white70 : Colors.black87),
                      size: 22,
                    ),
                    if (taskProvider.hasActiveSearchOrFilter)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AnimeColors.starlightGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = !_isSearchExpanded;
                    if (_isSearchExpanded) {
                      _searchFocusNode.requestFocus();
                    } else {
                      _searchFocusNode.unfocus();
                    }
                  });
                },
              ),

              // Petals Toggle Button
              IconButton(
                tooltip: _sakuraPetalsEnabled
                    ? 'Hide Sakura Petals'
                    : 'Show Sakura Petals',
                icon: Text(
                  _sakuraPetalsEnabled ? '🌸' : '🍃',
                  style: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  setState(() {
                    _sakuraPetalsEnabled = !_sakuraPetalsEnabled;
                  });
                },
              ),

              // Calendar Button
              IconButton(
                tooltip: 'Calendar View',
                icon: const Icon(Icons.calendar_month_outlined),
                color: AnimeColors.animeViolet,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                ),
              ),

              // Guild Stats Button
              IconButton(
                tooltip: 'Adventurer Guild Stats',
                icon: const Icon(Icons.insights_rounded),
                color: AnimeColors.sakuraPink,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Anime EXP Status Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF261E38), Color(0xFF1E172E)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFF0F5), Color(0xFFF7ECFF)],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AnimeColors.sakuraPink.withAlpha(isDark ? 60 : 40),
              ),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quest Progress ($completed / $total)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AnimeColors.textMainDark
                                  : AnimeColors.textMainLight,
                            ),
                          ),
                          Text(
                            total > 0
                                ? '${((completed / total) * 100).toInt()}%'
                                : '0%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AnimeColors.sakuraPink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: total > 0 ? (completed / total) : 0.0,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? Colors.white10
                              : AnimeColors.sakuraPink.withAlpha(30),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AnimeColors.sakuraPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSortPanel(
      BuildContext context, TaskProvider provider, bool isDark) {
    final ranks = [
      {'key': 'All', 'label': 'All Ranks', 'icon': '🛡️', 'color': AnimeColors.animeViolet},
      {'key': 'High', 'label': 'S-Rank', 'icon': '🔥', 'color': AnimeColors.rankS},
      {'key': 'Medium', 'label': 'A-Rank', 'icon': '⚡', 'color': AnimeColors.rankA},
      {'key': 'Low', 'label': 'B-Rank', 'icon': '🍃', 'color': AnimeColors.rankB},
    ];

    final sortOptions = [
      {'key': TaskSortOption.dueDate, 'label': 'Due Date', 'icon': '📅'},
      {'key': TaskSortOption.priority, 'label': 'Rank', 'icon': '⚡'},
      {'key': TaskSortOption.title, 'label': 'Title', 'icon': '🔤'},
      {'key': TaskSortOption.createdAt, 'label': 'Created', 'icon': '🕒'},
    ];

    String sortDirectionLabel() {
      switch (provider.sortBy) {
        case TaskSortOption.dueDate:
          return provider.sortAscending ? 'Soonest' : 'Furthest';
        case TaskSortOption.priority:
          return provider.sortAscending ? 'S → B' : 'B → S';
        case TaskSortOption.title:
          return provider.sortAscending ? 'A → Z' : 'Z → A';
        case TaskSortOption.createdAt:
          return provider.sortAscending ? 'Newest' : 'Oldest';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AnimeColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnimeColors.sakuraPink.withAlpha(isDark ? 80 : 50),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AnimeColors.sakuraPink.withAlpha(isDark ? 30 : 20),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Box
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AnimeColors.cardDarkSurface : AnimeColors.sakuraSubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) => provider.setSearchQuery(val),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AnimeColors.textMainDark : AnimeColors.textMainLight,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AnimeColors.sakuraPink,
                  size: 20,
                ),
                hintText: 'Search quests by title, notes, subtasks... 🗡️',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AnimeColors.textSubDark : AnimeColors.textSubLight,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        color: isDark ? Colors.white70 : Colors.black54,
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Priority / Rank Filter Chips
          Row(
            children: [
              const Text(
                '⚔️ PRIORITY / RANK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AnimeColors.sakuraPink,
                ),
              ),
              const Spacer(),
              if (provider.filterPriority != 'All')
                GestureDetector(
                  onTap: () => provider.setFilterPriority('All'),
                  child: const Text(
                    'Reset Rank',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AnimeColors.starlightGold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ranks.map((item) {
                final isSelected = provider.filterPriority == item['key'];
                final color = item['color'] as Color;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => provider.setFilterPriority(item['key'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withAlpha(isDark ? 70 : 40)
                            : (isDark ? AnimeColors.cardDarkSurface : Colors.grey.withAlpha(20)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item['icon'] as String, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? Colors.white : color)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Quick Sort Options & Direction Toggle
          Row(
            children: [
              const Text(
                '⚡ SORT BY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AnimeColors.animeViolet,
                ),
              ),
              const Spacer(),
              // Direction toggle button
              GestureDetector(
                onTap: () => provider.toggleSortDirection(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AnimeColors.animeViolet.withAlpha(isDark ? 50 : 25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AnimeColors.animeViolet.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 13,
                        color: AnimeColors.animeViolet,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sortDirectionLabel(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AnimeColors.animeViolet,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: sortOptions.map((item) {
                final isSelected = provider.sortBy == item['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => provider.setSortOption(item['key'] as TaskSortOption),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AnimeColors.animeViolet.withAlpha(isDark ? 70 : 35)
                            : (isDark ? AnimeColors.cardDarkSurface : Colors.grey.withAlpha(20)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AnimeColors.animeViolet : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item['icon'] as String, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? Colors.white : AnimeColors.animeViolet)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 4. Quick Reset Bar (if any filter or search active)
          if (provider.hasActiveSearchOrFilter) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AnimeColors.starlightGold.withAlpha(isDark ? 30 : 25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Showing ${provider.tasks.length} of ${provider.allTasks.length} quests',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AnimeColors.textMainDark : AnimeColors.textMainLight,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      provider.clearSearchAndFilters();
                    },
                    child: const Text(
                      'Clear All 🔄',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AnimeColors.sakuraPink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(
      BuildContext context, TaskProvider provider, bool isDark) {
    final statuses = [
      {'key': 'All', 'label': 'All Quests', 'icon': '📜'},
      {'key': 'Pending', 'label': 'Active', 'icon': '⚔️'},
      {'key': 'Completed', 'label': 'Cleared', 'icon': '🏆'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: statuses.map((item) {
          final isSelected = provider.filterStatus == item['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setFilterStatus(item['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AnimeColors.sakuraGradient : null,
                  color: isSelected
                      ? null
                      : (isDark
                          ? AnimeColors.cardDark
                          : Colors.white.withAlpha(200)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AnimeColors.sakuraPink.withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      item['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, TaskProvider provider) {
    final bool isSearchFilterEmpty =
        provider.allTasks.isNotEmpty && provider.tasks.isEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimeChibiMascot(
              size: 130,
              mood: isSearchFilterEmpty ? 'quest' : 'sleeping',
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AnimeColors.mysticVioletGradient.createShader(bounds),
              child: Text(
                isSearchFilterEmpty
                    ? '該当なし • No Quests Matched!'
                    : 'クエストなし • No Quests Active!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchFilterEmpty
                  ? 'No quests match your current search query or rank filter.\nTry adjusting your filters or resetting them! 🔍'
                  : 'Your mission board is currently clear.\nSummon a new quest to begin your adventure! ✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AnimeColors.textSubDark : AnimeColors.textSubLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (isSearchFilterEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  provider.clearSearchAndFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnimeColors.animeViolet,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Reset Filters 🔄',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnimeColors.sakuraPink,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Summon Quest ✨',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimeFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: AnimeColors.sakuraGradient,
        boxShadow: [
          BoxShadow(
            color: AnimeColors.sakuraPink.withAlpha(120),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'New Quest ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}