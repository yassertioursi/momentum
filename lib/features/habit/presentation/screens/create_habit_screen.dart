import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../domain/entities/habit.dart';
import '../../../../domain/repositories/habit_repository.dart';
import '../../../../injection_container.dart';

class CreateHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;

  const CreateHabitScreen({super.key, this.habitToEdit});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedIcon = 'check_circle';
  int _selectedColorIndex = 0;
  String _selectedCategory = 'health';
  String _frequencyType = 'daily';
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  String? _reminderTime;
  bool _reminderEnabled = false;

  bool get isEditing => widget.habitToEdit != null;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'check_circle', 'icon': Icons.check_circle},
    {'name': 'water_drop', 'icon': Icons.water_drop},
    {'name': 'menu_book', 'icon': Icons.menu_book},
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'self_improvement', 'icon': Icons.self_improvement},
    {'name': 'edit_note', 'icon': Icons.edit_note},
    {'name': 'bedtime', 'icon': Icons.bedtime},
    {'name': 'code', 'icon': Icons.code},
    {'name': 'music_note', 'icon': Icons.music_note},
    {'name': 'brush', 'icon': Icons.brush},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'savings', 'icon': Icons.savings},
    {'name': 'favorite', 'icon': Icons.favorite},
    {'name': 'star', 'icon': Icons.star},
    {'name': 'local_florist', 'icon': Icons.local_florist},
  ];

  final List<String> _categories = [
    'health',
    'productivity',
    'mindfulness',
    'learning',
    'fitness',
    'finance',
    'social',
    'creativity',
    'other',
  ];

  final List<String> _frequencyTypes = [
    'daily',
    'weekdays',
    'weekends',
    'custom',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      _titleController.text = widget.habitToEdit!.title;
      _notesController.text = widget.habitToEdit!.notes ?? '';
      _selectedIcon = widget.habitToEdit!.icon;
      _selectedColorIndex = AppColors.habitColors.indexWhere(
        (c) => c.value == widget.habitToEdit!.colorValue,
      ).clamp(0, AppColors.habitColors.length - 1);
      _selectedCategory = widget.habitToEdit!.category;
      _frequencyType = widget.habitToEdit!.frequencyType;
      _selectedDays = List.from(widget.habitToEdit!.frequencyDays);
      _reminderTime = widget.habitToEdit!.reminderTime;
      _reminderEnabled = widget.habitToEdit!.reminderEnabled;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      id: widget.habitToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      icon: _selectedIcon,
      colorValue: AppColors.habitColors[_selectedColorIndex].value,
      category: _selectedCategory,
      frequencyType: _frequencyType,
      frequencyDays: _selectedDays,
      reminderTime: _reminderTime,
      reminderEnabled: _reminderEnabled,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.habitToEdit?.createdAt ?? DateTime.now(),
    );

    await sl.get<HabitRepository>().saveHabit(habit);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay(
              hour: int.parse(_reminderTime!.split(':')[0]),
              minute: int.parse(_reminderTime!.split(':')[1]),
            )
          : TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _reminderTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                hintText: 'e.g., Drink Water',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon Selection
            Text(
              'Icon',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(_icons.length, (index) {
                final icon = _icons[index];
                final isSelected = _selectedIcon == icon['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon['name']),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      ),
                    ),
                    child: Icon(
                      icon['icon'],
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color Selection
            Text(
              'Color',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(AppColors.habitColors.length, (index) {
                final color = AppColors.habitColors[index];
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Category
            Text(
              'Category',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(_getCategoryDisplayName(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Frequency
            Text(
              'Frequency',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _frequencyTypes.map((type) {
                final isSelected = _frequencyType == type;
                return ChoiceChip(
                  label: Text(_getFrequencyDisplayName(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _frequencyType = type;
                        _updateSelectedDays(type);
                      });
                    }
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                );
              }).toList(),
            ),

            // Custom Days Selection
            if (_frequencyType == 'custom') ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1;
                  final isSelected = _selectedDays.contains(dayNumber);
                  return FilterChip(
                    label: Text(_getDayName(dayNumber)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(dayNumber);
                        } else {
                          _selectedDays.remove(dayNumber);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : null,
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Reminder
            Text(
              'Reminder',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: const Text('Enable Reminder'),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                  if (value && _reminderTime == null) {
                    _reminderTime = '09:00';
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_reminderEnabled)
              ListTile(
                title: const Text('Reminder Time'),
                trailing: Text(
                  _reminderTime ?? 'Select Time',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: _selectTime,
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: AppSpacing.lg),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about this habit',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Save Button
            GradientButton(
              text: isEditing ? 'Save Changes' : 'Create Habit',
              icon: Icons.check,
              onPressed: _saveHabit,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _updateSelectedDays(String type) {
    switch (type) {
      case 'daily':
        _selectedDays = [1, 2, 3, 4, 5, 6, 7];
        break;
      case 'weekdays':
        _selectedDays = [1, 2, 3, 4, 5];
        break;
      case 'weekends':
        _selectedDays = [6, 7];
        break;
    }
  }

  String _getCategoryDisplayName(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }

  String _getFrequencyDisplayName(String type) {
    switch (type) {
      case 'daily':
        return 'Daily';
      case 'weekdays':
        return 'Weekdays';
      case 'weekends':
        return 'Weekends';
      case 'custom':
        return 'Custom';
      default:
        return type;
    }
  }

  String _getDayName(int day) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[day - 1];
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await sl.get<HabitRepository>().deleteHabit(widget.habitToEdit!.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
