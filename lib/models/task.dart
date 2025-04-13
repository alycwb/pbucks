enum TaskStatus { pending, completed, approved }

class Task {
  final String id;
  final String title;
  final String description;
  final double pbuckValue;
  final String parentId;
  final List<String> childIds;
  final DateTime createdAt;
  final DateTime? dueDate;
  TaskStatus status;
  String? proofImageUrl;
  Map<String, TaskStatus> childStatuses;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.pbuckValue,
    required this.parentId,
    required this.childIds,
    required this.createdAt,
    this.dueDate,
    this.status = TaskStatus.pending,
    this.proofImageUrl,
    Map<String, TaskStatus>? childStatuses,
  }) : childStatuses = childStatuses ?? 
          Map.fromIterable(
            childIds, 
            key: (k) => k as String, 
            value: (_) => TaskStatus.pending
          );

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pbuckValue: json['pbuckValue']?.toDouble() ?? 0.0,
      parentId: json['parentId'],
      childIds: List<String>.from(json['childIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: TaskStatus.values.firstWhere(
        (status) => status.toString() == 'TaskStatus.${json['status']}',
      ),
      proofImageUrl: json['proofImageUrl'],
      childStatuses: (json['childStatuses'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          TaskStatus.values.firstWhere(
            (status) => status.toString() == 'TaskStatus.$value',
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pbuckValue': pbuckValue,
      'parentId': parentId,
      'childIds': childIds,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'proofImageUrl': proofImageUrl,
      'childStatuses': childStatuses.map(
        (key, value) => MapEntry(key, value.toString().split('.').last),
      ),
    };
  }

  bool get isCompletedByAll => 
    childIds.isNotEmpty && 
    childIds.every((id) => 
      childStatuses[id] == TaskStatus.completed || 
      childStatuses[id] == TaskStatus.approved
    );

  bool get isApprovedForAll =>
    childIds.isNotEmpty &&
    childIds.every((id) => childStatuses[id] == TaskStatus.approved);
} 