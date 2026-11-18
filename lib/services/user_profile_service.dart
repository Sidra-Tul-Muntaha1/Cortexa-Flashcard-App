import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileService extends ChangeNotifier {
  static const String _profileKey = 'codealpha_user_profile_v1';

  UserProfile _profile = const UserProfile();
  bool _isLoading = true;

  UserProfile get profile {
    _checkAndResetDateIfNeeded();
    return _profile;
  }

  bool get isLoading => _isLoading;

  UserProfileService() {
    init();
  }

  static String getTodayDateString() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool _checkAndResetDateIfNeeded() {
    final today = getTodayDateString();
    if (_profile.lastStudyDate.isEmpty) {
      _profile = _profile.copyWith(lastStudyDate: today);
      _saveProfile();
      return true;
    } else if (_profile.lastStudyDate != today) {
      _profile = _profile.copyWith(
        reviewsToday: 0,
        lastStudyDate: today,
      );
      _saveProfile();
      return true;
    }
    return false;
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_profileKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        _profile = UserProfile.fromMap(decoded);
      } else {
        _profile = UserProfile(lastStudyDate: getTodayDateString());
      }
      _checkAndResetDateIfNeeded();
      await _saveProfile();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _profile = UserProfile(lastStudyDate: getTodayDateString());
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordReview() async {
    _checkAndResetDateIfNeeded();
    _profile = _profile.copyWith(
      reviewsToday: _profile.reviewsToday + 1,
      lastStudyDate: getTodayDateString(),
    );
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateProfile({
    String? name,
    String? avatar,
    String? title,
    int? dailyGoal,
    int? streakDays,
  }) async {
    final safeGoal = dailyGoal != null
        ? (dailyGoal <= 0 ? _profile.dailyGoal : dailyGoal)
        : null;

    _profile = _profile.copyWith(
      name: name,
      avatar: avatar,
      title: title,
      dailyGoal: safeGoal,
      streakDays: streakDays,
    );
    notifyListeners();
    await _saveProfile();
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_profile.toMap());
      await prefs.setString(_profileKey, jsonString);
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  Future<void> resetProfile() async {
    _profile = const UserProfile();
    notifyListeners();
    await _saveProfile();
  }
}
