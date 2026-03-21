import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeding.dart';

class FeedingProvider extends ChangeNotifier {
  List<Feeding> _feedings = [];
  static const String _storageKey = 'feedings';

  List<Feeding> get feedings => List.unmodifiable(_feedings);

  List<Feeding> get todayFeedings {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _feedings
        .where((f) => f.dateTime.isAfter(startOfDay))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  double get todayTotalMl {
    return todayFeedings
        .where((f) => f.type == FeedingType.bottle)
        .fold(0.0, (sum, f) => sum + (f.amountMl ?? 0));
  }

  int get todayTotalBreastMinutes {
    return todayFeedings
        .where((f) => f.type == FeedingType.breast)
        .fold(0, (sum, f) => sum + (f.durationMinutes ?? 0));
  }

  int get todayFeedingCount => todayFeedings.length;

  Duration? get timeSinceLastFeeding {
    if (_feedings.isEmpty) return null;
    final sorted = List<Feeding>.from(_feedings)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return DateTime.now().difference(sorted.first.dateTime);
  }

  List<Feeding> getFeedingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _feedings
        .where((f) =>
            f.dateTime.isAfter(startOfDay) && f.dateTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> loadFeedings() async {
    final prefs = await SharedPreferences.getInstance();
    final feedingsString = prefs.getString(_storageKey);
    if (feedingsString != null && feedingsString.isNotEmpty) {
      _feedings = Feeding.decode(feedingsString);
    }
    notifyListeners();
  }

  Future<void> addFeeding(Feeding feeding) async {
    _feedings.add(feeding);
    await _saveFeedings();
    notifyListeners();
  }

  Future<void> removeFeeding(String id) async {
    _feedings.removeWhere((f) => f.id == id);
    await _saveFeedings();
    notifyListeners();
  }

  Future<void> _saveFeedings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Feeding.encode(_feedings));
  }
}
