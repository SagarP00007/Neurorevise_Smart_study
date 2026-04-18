import 'package:flutter/material.dart';
import 'package:study_smart/core/theme/app_theme.dart';

class PlannerView extends StatefulWidget {
  const PlannerView({super.key});

  @override
  State<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  DateTime _selected = DateTime.now();
  final List<_Task> _tasks = [
    _Task(title: 'Read Chapter 5', subject: 'CS', time: '09:00 AM'),
    _Task(title: 'Practice Integration', subject: 'Math', time: '11:00 AM'),
    _Task(title: 'Review Notes', subject: 'Biology', time: '02:00 PM'),
    _Task(title: 'Revise Flashcards', subject: 'Chemistry', time: '04:30 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddTask(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Week Strip
          _WeekStrip(
            selected: _selected,
            onTap: (d) => setState(() => _selected = d),
          ),
          const Divider(height: 1),
          // Task List
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Text('No tasks for today. Add one!',
                        style: theme.textTheme.bodyMedium),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _TaskCard(task: _tasks[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Task',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Task title')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(hintText: 'Subject')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Task {
  String title;
  String subject;
  String time;
  bool done;
  _Task({required this.title, required this.subject, required this.time, this.done = false});
}

class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final void Function(DateTime) onTap;
  const _WeekStrip({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final day = days[i];
          final isSelected = day.day == selected.day &&
              day.month == selected.month;
          final isToday =
              day.day == today.day && day.month == today.month;
          return GestureDetector(
            onTap: () => onTap(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : isToday
                        ? AppTheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.primary, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final _Task task;
  const _TaskCard({required this.task});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => widget.task.done = !widget.task.done),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.task.done ? AppTheme.secondary : Colors.transparent,
                  border: Border.all(
                    color: widget.task.done
                        ? AppTheme.secondary
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: widget.task.done
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      decoration: widget.task.done
                          ? TextDecoration.lineThrough
                          : null,
                      color: widget.task.done
                          ? theme.colorScheme.onSurface.withOpacity(0.4)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(widget.task.subject, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.task.time,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
