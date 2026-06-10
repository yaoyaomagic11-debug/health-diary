class DailyRecord {
  final String date;
  int waterMl;
  String exerciseType;
  int exerciseMinutes;
  int caloriesKcal;
  String notes;

  DailyRecord({
    required this.date,
    this.waterMl = 0,
    this.exerciseType = '',
    this.exerciseMinutes = 0,
    this.caloriesKcal = 0,
    this.notes = '',
  });

  bool get hasData =>
      waterMl > 0 || exerciseType.isNotEmpty || caloriesKcal > 0 || notes.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'date': date,
        'waterMl': waterMl,
        'exerciseType': exerciseType,
        'exerciseMinutes': exerciseMinutes,
        'caloriesKcal': caloriesKcal,
        'notes': notes,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        date: json['date'] as String,
        waterMl: json['waterMl'] as int? ?? 0,
        exerciseType: json['exerciseType'] as String? ?? '',
        exerciseMinutes: json['exerciseMinutes'] as int? ?? 0,
        caloriesKcal: json['caloriesKcal'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}
