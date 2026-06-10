import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_record.dart';

class StorageService {
  static const String _recordsKey = 'records';
  static const String _exerciseTypesKey = 'exercise_types';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  DailyRecord? getRecord(String date) {
    final data = _getAllRecordsMap();
    final json = data[date];
    if (json == null) return null;
    return DailyRecord.fromJson(json);
  }

  Future<void> saveRecord(DailyRecord record) async {
    final data = _getAllRecordsMap();
    data[record.date] = record.toJson();
    await _prefs.setString(_recordsKey, jsonEncode(data));
  }

  List<DailyRecord> getAllRecords() {
    return _getAllRecordsMap()
        .values
        .map((json) => DailyRecord.fromJson(json))
        .toList();
  }

  Set<DateTime> getDatesWithRecords() {
    return _getAllRecordsMap()
        .keys
        .map((k) {
          final parts = k.split('-');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
          return null;
        })
        .whereType<DateTime>()
        .toSet();
  }

  List<String> getExerciseTypes() {
    return _prefs.getStringList(_exerciseTypesKey) ?? [];
  }

  Future<void> saveExerciseTypes(List<String> types) async {
    await _prefs.setStringList(_exerciseTypesKey, types);
  }

  Future<void> addExerciseType(String type) async {
    final types = getExerciseTypes();
    final trimmed = type.trim();
    if (!types.contains(trimmed) && trimmed.isNotEmpty) {
      types.insert(0, trimmed);
      await saveExerciseTypes(types);
    }
  }

  Future<void> removeExerciseType(String type) async {
    final types = getExerciseTypes();
    types.remove(type);
    await saveExerciseTypes(types);
  }

  Map<String, Map<String, dynamic>> _getAllRecordsMap() {
    final raw = _prefs.getString(_recordsKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as Map<String, dynamic>));
  }
}
