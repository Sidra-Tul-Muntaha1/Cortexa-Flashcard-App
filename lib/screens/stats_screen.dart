import 'package:flutter/material.dart';
import '../models/deck_category.dart';
import '../models/user_profile.dart';
import '../services/flashcard_service.dart';
import '../services/theme_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/edit_profile_dialog.dart';

class StatsScreen extends StatefulWidget {
  final FlashcardService flashcardService;
  final ThemeService themeService;
  final UserProfileService? profileService;

  const StatsScreen({
    super.key,
    required this.flashcardService,
    required this.themeService,
    this.profileService,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late UserProfileService _profileService;
  bool _internalService = false;

  @override
  void initState() {
    super.initState();
    if (widget.profileService != null) {
      _profileService = widget.profileService!;
    } else {
      _profileService = UserProfileService();
      _internalService = true;
    }
    _profileService.addListener(_onProfileChange);
  }

  void _onProfileChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileChange);
    if (_internalService) {
      _profileService.dispose();
    }
    super.dispose();
  }

  void _openEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileDialog(
        profileService: _profileService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.flashcardService.totalCards;
    final totalReviews = widget.flashcardService.totalReviews;
    final accuracy = widget.flashcardService.overallAccuracy.round();
    final mastered = widget.flashcardService.masteredCount;
    final favorites = widget.flashcardService.favoriteCards.length;
    final profile = _profileService.profile;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profile & Learning Stats',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.manage_accounts_rounded),
            onPressed: () => _openEditProfileDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Section
            _buildProfileSection(context, isDark, profile),

            const SizedBox(height: 20),

            // Hero Analytics Overview Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4A6), Color(0xFF1A2E5A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4A6).withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mastery Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              UserProfile.calculateRankTitle(totalReviews),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _buildHeroStat('$accuracy%', 'Quiz Accuracy', Icons.track_changes_rounded)),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Expanded(child: _buildHeroStat('$totalReviews', 'Total Reviews', Icons.repeat_rounded)),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Expanded(child: _buildHeroStat('$mastered', 'Cards Mastered', Icons.verified_rounded)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Cards',
                    value: '$total',
                    icon: Icons.style_rounded,
                    color: const Color(0xFF0EA5E9),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Favorites',
                    value: '$favorites',
                    icon: Icons.favorite_rounded,
                    color: const Color(0xFFEF4444),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Decks & Category Distribution
            Text(
              'Decks Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2433) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.flashcardService.categories
                    .where((c) => c != 'All Decks')
                    .map((catName) {
                  final cat = DeckCategory.getCategory(catName);
                  final count = widget.flashcardService.cards.where((c) => c.category.toLowerCase() == catName.toLowerCase()).length;
                  final percentage = total == 0 ? 0.0 : (count / total);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(cat.icon, size: 16, color: cat.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                catName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count ${count == 1 ? 'card' : 'cards'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 6,
                            backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(cat.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // App Settings & Preferences
            Text(
              'Profile & App Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),

            Material(
              color: isDark ? const Color(0xFF1E2433) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4A6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline_rounded, color: Color(0xFF00B4A6), size: 20),
                    ),
                    title: const Text('Edit Learner Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      '${profile.name} • ${profile.dailyGoal} cards/day goal',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => _openEditProfileDialog(context),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dark_mode_rounded, color: Color(0xFF6366F1), size: 20),
                    ),
                    title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      widget.themeService.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: widget.themeService.isDarkMode,
                      activeThumbColor: const Color(0xFF00B4A6),
                      onChanged: (_) => widget.themeService.toggleTheme(),
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restart_alt_rounded, color: Color(0xFF10B981), size: 20),
                    ),
                    title: const Text('Restore Default Decks', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Reset flashcards to default collection', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      await widget.flashcardService.resetToDefaults();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Default flashcards restored! ✨'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isDark, UserProfile profile) {
    final totalReviews = widget.flashcardService.totalReviews;
    final level = UserProfile.calculateLevel(totalReviews);
    final rankTitle = UserProfile.calculateRankTitle(totalReviews);
    final target = profile.dailyGoal <= 0 ? 15 : profile.dailyGoal;
    final progressCount = profile.reviewsToday.clamp(0, target * 100);
    final progressRatio = target <= 0 ? 0.0 : (progressCount / target).clamp(0.0, 1.0);
    final isGoalAchieved = target > 0 && progressCount >= target;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Avatar, Info, Edit button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openEditProfileDialog(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildAvatarWidget(profile.avatar, 64, showBorder: true),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00B4A6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Rank / Level Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4A6).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.military_tech_rounded,
                            color: Color(0xFF00B4A6),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Level $level • $rankTitle',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00B4A6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Edit Profile Button
              IconButton(
                tooltip: 'Edit Profile',
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: Color(0xFF00B4A6),
                ),
                onPressed: () => _openEditProfileDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 14),

          // Daily Goal Progress section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.flag_circle_rounded,
                    color: Color(0xFF00B4A6),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Daily Goal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '$progressCount / $target cards',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isGoalAchieved ? const Color(0xFF10B981) : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 7,
              backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                isGoalAchieved ? const Color(0xFF10B981) : const Color(0xFF00B4A6),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom stats: Streak & Member since
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${profile.streakDays} Day Streak',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: isDark ? Colors.white38 : Colors.black38,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Joined ${profile.joinedDate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(String avatar, double size, {bool showBorder = false}) {
    Widget inner;
    Color bgColor = const Color(0xFF00B4A6);

    switch (avatar) {
      case 'scholar':
        bgColor = const Color(0xFF6366F1);
        inner = Icon(Icons.school_rounded, color: Colors.white, size: size * 0.55);
        break;
      case 'rocket':
        bgColor = const Color(0xFF8B5CF6);
        inner = Icon(Icons.rocket_launch_rounded, color: Colors.white, size: size * 0.55);
        break;
      case 'lightning':
        bgColor = const Color(0xFFF59E0B);
        inner = Icon(Icons.bolt_rounded, color: Colors.white, size: size * 0.55);
        break;
      case 'fire':
        bgColor = const Color(0xFFEF4444);
        inner = Icon(Icons.local_fire_department_rounded, color: Colors.white, size: size * 0.55);
        break;
      case 'bulb':
        bgColor = const Color(0xFF10B981);
        inner = Icon(Icons.lightbulb_rounded, color: Colors.white, size: size * 0.55);
        break;
      case 'trophy':
        bgColor = const Color(0xFFEAB308);
        inner = Icon(Icons.emoji_events_rounded, color: Colors.white, size: size * 0.55);
        break;
      case 'star':
        bgColor = const Color(0xFF0EA5E9);
        inner = Icon(Icons.star_rounded, color: Colors.white, size: size * 0.55);
        break;
      case 'mascot':
      default:
        bgColor = const Color(0xFF00B4A6).withValues(alpha: 0.15);
        inner = Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Image.asset(
            'assets/images/brain_mascot.png',
            fit: BoxFit.contain,
          ),
        );
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: showBorder
            ? Border.all(color: Colors.white, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: inner),
    );
  }

  Widget _buildHeroStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
