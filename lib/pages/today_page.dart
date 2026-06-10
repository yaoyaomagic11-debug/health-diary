import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/health_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/exercise_type_picker.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthState>(
      builder: (context, state, _) {
        final record = state.todayRecord;
        final now = DateTime.now();
        final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        final dateStr =
            '${now.year}年${now.month}月${now.day}日 ${weekdayNames[now.weekday - 1]}';

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text('健康日记', style: TextStyle(fontSize: 18)),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 100),
            child: Column(
              children: [
                MetricCard(
                  icon: Icons.water_drop,
                  title: '饮水量',
                  valueText: '${record.waterMl}',
                  unit: 'ml',
                  step: 100,
                  onDecrement: () =>
                      state.updateWaterMl(record.waterMl - 100),
                  onIncrement: () =>
                      state.updateWaterMl(record.waterMl + 100),
                  onTapValue: () => _showNumberInput(
                    context: context,
                    title: '输入饮水量 (ml)',
                    currentValue: record.waterMl,
                    onSave: state.updateWaterMl,
                  ),
                ),
                MetricCard(
                  icon: Icons.directions_run,
                  title: '运动',
                  valueText: '${record.exerciseMinutes}',
                  unit: '分钟',
                  step: 5,
                  extraHeader: _ExerciseTypeChip(
                    currentType: record.exerciseType,
                    types: state.exerciseTypes,
                    onSelected: state.updateExerciseType,
                    onAdd: state.addExerciseType,
                    onRemove: state.removeExerciseType,
                  ),
                  onDecrement: () =>
                      state.updateExerciseMinutes(record.exerciseMinutes - 5),
                  onIncrement: () =>
                      state.updateExerciseMinutes(record.exerciseMinutes + 5),
                  onTapValue: () => _showNumberInput(
                    context: context,
                    title: '输入运动时长 (分钟)',
                    currentValue: record.exerciseMinutes,
                    onSave: state.updateExerciseMinutes,
                  ),
                ),
                MetricCard(
                  icon: Icons.local_fire_department,
                  title: '饮食热量',
                  valueText: '${record.caloriesKcal}',
                  unit: 'kcal',
                  step: 50,
                  onDecrement: () =>
                      state.updateCaloriesKcal(record.caloriesKcal - 50),
                  onIncrement: () =>
                      state.updateCaloriesKcal(record.caloriesKcal + 50),
                  onTapValue: () => _showNumberInput(
                    context: context,
                    title: '输入饮食热量 (kcal)',
                    currentValue: record.caloriesKcal,
                    onSave: state.updateCaloriesKcal,
                  ),
                ),
                const SizedBox(height: 12),
                _NotesSection(
                  notes: record.notes,
                  onChanged: state.updateNotes,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await state.saveTodayRecord();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('保存成功'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('保存记录',
                          style: TextStyle(fontSize: 16)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7EC8A0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNumberInput({
    required BuildContext context,
    required String title,
    required int currentValue,
    required ValueChanged<int> onSave,
  }) {
    final controller = TextEditingController(
        text: currentValue > 0 ? currentValue.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              onSave(value);
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTypeChip extends StatelessWidget {
  final String currentType;
  final List<String> types;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _ExerciseTypeChip({
    required this.currentType,
    required this.types,
    required this.onSelected,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showExerciseTypePicker(
        context: context,
        types: types,
        selectedType: currentType,
        onSelected: onSelected,
        onAdd: onAdd,
        onRemove: onRemove,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentType.isNotEmpty ? currentType : '选择类型',
              style: TextStyle(
                color: currentType.isNotEmpty
                    ? const Color(0xFF2E7D32)
                    : Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 18, color: const Color(0xFF7EC8A0)),
          ],
        ),
      ),
    );
  }
}

class _NotesSection extends StatefulWidget {
  final String notes;
  final ValueChanged<String> onChanged;

  const _NotesSection({required this.notes, required this.onChanged});

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.notes);
  }

  @override
  void didUpdateWidget(covariant _NotesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notes != oldWidget.notes &&
        widget.notes != _controller.text) {
      _controller.text = widget.notes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: Theme.of(context).colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  '日记备注',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '今天过得怎么样？天气、心情、碎碎念...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
