import 'package:flutter/material.dart';

class ExerciseTypePicker extends StatefulWidget {
  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const ExerciseTypePicker({
    super.key,
    required this.types,
    required this.selectedType,
    required this.onSelected,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<ExerciseTypePicker> createState() => _ExerciseTypePickerState();
}

class _ExerciseTypePickerState extends State<ExerciseTypePicker> {
  final _controller = TextEditingController();

  void _submitNewType() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      widget.onAdd(value);
      widget.onSelected(value);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final types = widget.types;
    final selectedType = widget.selectedType;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择运动类型',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '长按可删除历史类型',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 12),
            if (types.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: types.map((type) {
                  final isSelected = type == selectedType;
                  return GestureDetector(
                    onLongPress: () => _confirmDelete(context, type),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) {
                        widget.onSelected(type);
                        Navigator.pop(context);
                      },
                      selectedColor: const Color(0xFF7EC8A0),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: types.isEmpty,
                    decoration: const InputDecoration(
                      hintText: '输入新运动类型',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _submitNewType(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _submitNewType,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF7EC8A0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除运动类型'),
        content: Text('确定要删除「$type」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemove(type);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

void showExerciseTypePicker({
  required BuildContext context,
  required List<String> types,
  required String selectedType,
  required ValueChanged<String> onSelected,
  required ValueChanged<String> onAdd,
  required ValueChanged<String> onRemove,
}) {
  showDialog(
    context: context,
    builder: (_) => ExerciseTypePicker(
      types: types,
      selectedType: selectedType,
      onSelected: onSelected,
      onAdd: onAdd,
      onRemove: onRemove,
    ),
  );
}
