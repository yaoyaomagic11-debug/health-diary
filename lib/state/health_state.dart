import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';

class HealthState extends ChangeNotifier {
  final StorageService _storage;

  HealthState(this._storage);

  DailyRecord todayRecord = DailyRecord(date: _todayString());
  List<String> exerciseTypes = [];
  List<DailyRecord> allRecords = [];

  static String _todayString() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> init() async {
    await _storage.init();
    _loadExerciseTypes();
    _loadAllRecords();
    _loadTodayRecord();
  }

  void _loadExerciseTypes() {
    exerciseTypes = _storage.getExerciseTypes();
  }

  void _loadAllRecords() {
    allRecords = _storage.getAllRecords();
  }

  void _loadTodayRecord() {
    final saved = _storage.getRecord(todayRecord.date);
    if (saved != null) {
      todayRecord = saved;
    } else {
      todayRecord = DailyRecord(date: todayRecord.date);
    }
    notifyListeners();
  }

  void loadRecordForDate(String date) {
    final saved = _storage.getRecord(date);
    if (saved != null) {
      todayRecord = saved;
      notifyListeners();
    }
  }

  DailyRecord? getRecordForDate(String date) {
    return _storage.getRecord(date);
  }

  Set<DateTime> get datesWithRecords => _storage.getDatesWithRecords();

  Future<void> saveTodayRecord() async {
    await _storage.saveRecord(todayRecord);

    if (todayRecord.exerciseType.trim().isNotEmpty &&
        !exerciseTypes.contains(todayRecord.exerciseType.trim())) {
      exerciseTypes.insert(0, todayRecord.exerciseType.trim());
      await _storage.saveExerciseTypes(exerciseTypes);
    }

    _loadAllRecords();
    notifyListeners();
  }

  Future<void> addExerciseType(String type) async {
    await _storage.addExerciseType(type);
    _loadExerciseTypes();
    notifyListeners();
  }

  Future<void> removeExerciseType(String type) async {
    await _storage.removeExerciseType(type);
    _loadExerciseTypes();
    notifyListeners();
  }

  void updateWaterMl(int value) {
    todayRecord.waterMl = (value < 0) ? 0 : value;
    notifyListeners();
  }

  void updateExerciseMinutes(int value) {
    todayRecord.exerciseMinutes = (value < 0) ? 0 : value;
    notifyListeners();
  }

  void updateExerciseType(String type) {
    todayRecord.exerciseType = type;
    notifyListeners();
  }

  void updateCaloriesKcal(int value) {
    todayRecord.caloriesKcal = (value < 0) ? 0 : value;
    notifyListeners();
  }

  void updateNotes(String notes) {
    todayRecord.notes = notes;
    notifyListeners();
  }
}
