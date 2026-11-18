class UserProfile {
  final String name;
  final String avatar; // 'mascot', 'scholar', 'rocket', 'lightning', 'fire', 'bulb', 'trophy', 'star'
  final String title;
  final int dailyGoal; // cards per day
  final int streakDays;
  final String joinedDate;
  final int reviewsToday;
  final String lastStudyDate; // 'YYYY-MM-DD'

  const UserProfile({
    this.name = 'Brain Champion',
    this.avatar = 'mascot',
    this.title = 'Active Scholar',
    this.dailyGoal = 15,
    this.streakDays = 5,
    this.joinedDate = 'October 2026',
    this.reviewsToday = 0,
    this.lastStudyDate = '',
  });

  UserProfile copyWith({
    String? name,
    String? avatar,
    String? title,
    int? dailyGoal,
    int? streakDays,
    String? joinedDate,
    int? reviewsToday,
    String? lastStudyDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      title: title ?? this.title,
      dailyGoal: dailyGoal != null
          ? (dailyGoal <= 0 ? 15 : dailyGoal)
          : this.dailyGoal,
      streakDays: streakDays ?? this.streakDays,
      joinedDate: joinedDate ?? this.joinedDate,
      reviewsToday: reviewsToday ?? this.reviewsToday,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'title': title,
      'dailyGoal': dailyGoal <= 0 ? 15 : dailyGoal,
      'streakDays': streakDays,
      'joinedDate': joinedDate,
      'reviewsToday': reviewsToday,
      'lastStudyDate': lastStudyDate,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final rawGoal = (map['dailyGoal'] as num?)?.toInt() ?? 15;
    return UserProfile(
      name: map['name'] as String? ?? 'Brain Champion',
      avatar: map['avatar'] as String? ?? 'mascot',
      title: map['title'] as String? ?? 'Active Scholar',
      dailyGoal: rawGoal <= 0 ? 15 : rawGoal,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 5,
      joinedDate: map['joinedDate'] as String? ?? 'October 2026',
      reviewsToday: (map['reviewsToday'] as num?)?.toInt() ?? 0,
      lastStudyDate: map['lastStudyDate'] as String? ?? '',
    );
  }

  static int calculateLevel(int totalReviews) {
    if (totalReviews >= 100) return 5;
    if (totalReviews >= 60) return 4;
    if (totalReviews >= 30) return 3;
    if (totalReviews >= 10) return 2;
    return 1;
  }

  static String calculateRankTitle(int totalReviews) {
    if (totalReviews >= 100) return 'Recall Grandmaster';
    if (totalReviews >= 60) return 'Knowledge Master';
    if (totalReviews >= 30) return 'Memory Champion';
    if (totalReviews >= 10) return 'Curious Scholar';
    return 'Apprentice Mind';
  }
}
