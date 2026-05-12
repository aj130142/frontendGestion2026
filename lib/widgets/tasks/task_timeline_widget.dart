import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';

class TaskTimelineWidget extends StatelessWidget {
  final List<AppTask> tasks;

  const TaskTimelineWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No hay tareas para mostrar en la línea de tiempo'));
    }

    // 1. Parse dates and find range
    DateTime? minDate;
    DateTime? maxDate;

    final List<_TaskWithDates> tasksWithDates = [];

    for (var task in tasks) {
      try {
        final start = DateTime.parse(task.startDate);
        final end = task.endDate != null ? DateTime.parse(task.endDate!) : start.add(const Duration(days: 1));
        
        tasksWithDates.add(_TaskWithDates(task, start, end));

        if (minDate == null || start.isBefore(minDate)) minDate = start;
        if (maxDate == null || end.isAfter(maxDate)) maxDate = end;
      } catch (e) {
        // Skip tasks with invalid dates
        continue;
      }
    }

    if (tasksWithDates.isEmpty || minDate == null || maxDate == null) {
      return const Center(child: Text('Las tareas no tienen fechas válidas para la línea de tiempo'));
    }

    // Add some padding to the range (e.g., 2 days)
    minDate = DateTime(minDate.year, minDate.month, minDate.day).subtract(const Duration(days: 1));
    maxDate = DateTime(maxDate.year, maxDate.month, maxDate.day).add(const Duration(days: 3));

    final totalDays = maxDate.difference(minDate).inDays;
    const double dayWidth = 60.0;
    const double rowHeight = 70.0;
    const double titleWidth = 150.0;

    return Column(
      children: [
        // Header with dates
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: titleWidth),
              ...List.generate(totalDays, (index) {
                final date = minDate!.add(Duration(days: index));
                final isToday = _isSameDay(date, DateTime.now());
                return Container(
                  width: dayWidth,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? Colors.teal.withOpacity(0.1) : null,
                    border: Border(
                      left: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      bottom: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? Colors.teal : Colors.grey,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? Colors.teal : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        // Timeline content
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Stack(
                children: [
                  // Vertical grid lines
                  Row(
                    children: [
                      const SizedBox(width: titleWidth),
                      ...List.generate(totalDays, (index) {
                        return Container(
                          width: dayWidth,
                          height: tasksWithDates.length * rowHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.grey.withOpacity(0.1)),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  // Task rows
                  Column(
                    children: tasksWithDates.map((item) {
                      final leftOffset = item.start.difference(minDate!).inDays * dayWidth;
                      final durationDays = item.end.difference(item.start).inDays.clamp(1, 1000);
                      final barWidth = durationDays * dayWidth;

                      return Container(
                        height: rowHeight,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
                        ),
                        child: Row(
                          children: [
                            // Task Title Column
                            Container(
                              width: titleWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.task.title,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Bar Area
                            SizedBox(
                              width: totalDays * dayWidth,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: leftOffset,
                                    top: 15,
                                    child: Tooltip(
                                      message: '${item.task.title}\n${DateFormat('dd/MM').format(item.start)} - ${DateFormat('dd/MM').format(item.end)}',
                                      child: Container(
                                        width: barWidth,
                                        height: 35,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(item.task.status).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          item.task.responsible,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
      case 'finalizada':
        return Colors.green;
      case 'en progreso':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }
}

class _TaskWithDates {
  final AppTask task;
  final DateTime start;
  final DateTime end;

  _TaskWithDates(this.task, this.start, this.end);
}
