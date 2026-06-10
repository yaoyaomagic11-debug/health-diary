import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../state/health_state.dart';
import '../models/daily_record.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthState>(
      builder: (context, state, _) {
        final datesWithRecords = state.datesWithRecords;

        return Scaffold(
          appBar: AppBar(title: const Text('日历回顾')),
          body: Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2024),
                lastDay: DateTime.now().add(const Duration(days: 1)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showDayRecord(context, state, selectedDay);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF7EC8A0).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF7EC8A0),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF7EC8A0),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  todayTextStyle: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon:
                      const Icon(Icons.chevron_left, color: Color(0xFF7EC8A0)),
                  rightChevronIcon: const Icon(Icons.chevron_right,
                      color: Color(0xFF7EC8A0)),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (datesWithRecords.any((d) => isSameDay(d, date))) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7EC8A0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                locale: 'zh_CN',
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7EC8A0),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '有记录的日期',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '共 ${datesWithRecords.length} 天记录',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDayRecord(
      BuildContext context, HealthState state, DateTime day) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    final record = state.getRecordForDate(dateStr);

    if (record == null || !record.hasData) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${day.month}月${day.day}日 暂无记录'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${day.month}月${day.day}日 记录',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _RecordRow(
                icon: Icons.water_drop, label: '饮水量', value: '${record.waterMl} ml'),
            _RecordRow(
                icon: Icons.directions_run,
                label: '运动',
                value: record.exerciseType.isNotEmpty
                    ? '${record.exerciseType}  ${record.exerciseMinutes}分钟'
                    : '未记录'),
            _RecordRow(
                icon: Icons.local_fire_department,
                label: '饮食热量',
                value: '${record.caloriesKcal} kcal'),
            if (record.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                '日记备注',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(record.notes,
                  style: const TextStyle(fontSize: 15, height: 1.5)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7EC8A0)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}
