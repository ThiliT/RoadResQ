import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/rating.dart';

class RatingService {
  static const String _ratingsKey = 'service_ratings';

  Future<List<Rating>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_ratingsKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Rating.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<Rating> ratings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ratings.map((r) => r.toJson()).toList();
    await prefs.setString(_ratingsKey, jsonEncode(jsonList));
  }

  Future<bool> hasRated(String serviceId) async {
    final all = await _loadAll();
    return all.any((r) => r.serviceId == serviceId);
  }

  Future<Rating?> getRatingForService(String serviceId) async {
    final all = await _loadAll();
    try {
      return all.firstWhere((r) => r.serviceId == serviceId);
    } catch (_) {
      return null;
    }
  }

  /// Adds a rating if one does not already exist for the given service.
  /// Returns the updated average rating for the mechanic.
  Future<double> addRating(Rating rating) async {
    final all = await _loadAll();
    final existingIndex = all.indexWhere((r) => r.serviceId == rating.serviceId);
    if (existingIndex != -1) {
      // Prevent duplicate ratings for the same service
      return getMechanicAverage(rating.mechanicId);
    }
    all.add(rating);
    await _saveAll(all);
    return getMechanicAverage(rating.mechanicId);
  }

  Future<double> getMechanicAverage(String mechanicId) async {
    final all = await _loadAll();
    final mechRatings = all.where((r) => r.mechanicId == mechanicId).toList();
    if (mechRatings.isEmpty) return 0;
    final sum = mechRatings.fold<int>(0, (acc, r) => acc + r.rating);
    return sum / mechRatings.length;
  }
}

