import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  static final GameProgress _instance = GameProgress._internal();

  factory GameProgress() => _instance;

  GameProgress._internal();

  final Map<String, int> _stars = {
    'basket': 0,
    'whack': 0,
    'belt': 0,
    'builder': 0,
    'quiz': 0,
  };

  int getStars(String gameId) => _stars[gameId] ?? 0;

  void setStars(String gameId, int stars) {
    _stars[gameId] = stars;
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _stars.entries) {
      await prefs.setInt('stars_${entry.key}', entry.value);
    }
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _stars.keys) {
      _stars[key] = prefs.getInt('stars_$key') ?? 0;
    }
  }

  Map<String, int> get allStars => _stars;
}
