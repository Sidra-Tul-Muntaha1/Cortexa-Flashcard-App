import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfileService profileService;

  const EditProfileDialog({
    super.key,
    required this.profileService,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late String _selectedAvatar;
  late int _selectedGoal;

  final List<Map<String, dynamic>> _avatarOptions = [
    {
      'id': 'mascot',
      'label': 'Mascot',
      'isImage': true,
      'asset': 'assets/images/brain_mascot.png',
      'color': const Color(0xFF00B4A6),
    },
    {
      'id': 'scholar',
      'label': 'Scholar',
      'isImage': false,
      'icon': Icons.school_rounded,
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'rocket',
      'label': 'Explorer',
      'isImage': false,
      'icon': Icons.rocket_launch_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'lightning',
      'label': 'Speed',
      'isImage': false,
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'fire',
      'label': 'Streak',
      'isImage': false,
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'bulb',
      'label': 'Genius',
      'isImage': false,
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'trophy',
      'label': 'Champ',
      'isImage': false,
      'icon': Icons.emoji_events_rounded,
      'color': const Color(0xFFEAB308),
    },
    {
      'id': 'star',
      'label': 'Master',
      'isImage': false,
      'icon': Icons.star_rounded,
      'color': const Color(0xFF0EA5E9),
    },
  ];

  final List<String> _titlePresets = [
    'Active Scholar',
    'Flashcard Pro',
    'Lifelong Learner',
    'Tech Explorer',
    'Language Buff',
    'Trivia Master',
  ];

  final List<int> _goalPresets = [5, 10, 15, 20, 25, 30];

  @override
  void initState() {
    super.initState();
    final profile = widget.profileService.profile;
    _nameController = TextEditingController(text: profile.name);
    _titleController = TextEditingController(text: profile.title);
    _selectedAvatar = profile.avatar;
    _selectedGoal = profile.dailyGoal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.profileService.updateProfile(
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        avatar: _selectedAvatar,
        dailyGoal: _selectedGoal <= 0 ? 15 : _selectedGoal,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Profile updated successfully!')),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4A6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF00B4A6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Learner Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Personalize your identity & study targets',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Avatar Selection Section
              Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _avatarOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _avatarOptions[index];
                    final isSelected = _selectedAvatar == item['id'];
                    final color = item['color'] as Color;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = item['id'] as String;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? color.withValues(alpha: 0.2)
                                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: item['isImage'] == true
                                ? Image.asset(
                                    item['asset'] as String,
                                    fit: BoxFit.contain,
                                  )
                                : Icon(
                                    item['icon'] as IconData,
                                    color: color,
                                    size: 26,
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? color : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Name Field
              Text(
                'Display Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                  hintText: 'Enter your name or nickname',
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF00B4A6), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  if (val.trim().length > 25) {
                    return 'Name is too long (max 25 chars)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Title / Tagline Field
              Text(
                'Learner Title / Study Focus',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school_outlined, size: 20),
                  hintText: 'e.g. Active Scholar, Biology Student',
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF00B4A6), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),

              // Title Preset Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _titlePresets.map((preset) {
                    final isSelected = _titleController.text == preset;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(
                          preset,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF00B4A6)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        backgroundColor: isSelected
                            ? const Color(0xFF00B4A6).withValues(alpha: 0.15)
                            : (isDark ? Colors.white10 : Colors.grey.shade100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF00B4A6) : Colors.transparent,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _titleController.text = preset;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Daily Goal Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Review Target',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4A6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_selectedGoal cards/day',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B4A6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: _goalPresets.map((g) {
                  final isSelected = _selectedGoal == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGoal = g;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00B4A6)
                              : (isDark ? Colors.white10 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00B4A6) : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$g',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4A6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
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
