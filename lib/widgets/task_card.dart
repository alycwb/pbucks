import 'package:flutter/material.dart';
import '../models/task.dart';
import '../constants/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool isParentView;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.isParentView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${task.pbuckValue.toInt()} PB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(),
                  if (!isParentView && task.status == TaskStatus.pending)
                    TextButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark Complete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (task.status) {
      case TaskStatus.pending:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        label = 'Pending';
        icon = Icons.schedule;
        break;
      case TaskStatus.completed:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        label = 'Completed';
        icon = Icons.done;
        break;
      case TaskStatus.approved:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        label = 'Approved';
        icon = Icons.verified;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 