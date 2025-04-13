enum RewardStatus { available, redeemed }

class Reward {
  final String id;
  final String title;
  final String description;
  final double pbuckCost;
  final String parentId;
  final bool isAvailable;
  final DateTime createdAt;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pbuckCost,
    required this.parentId,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pbuckCost: json['pbuckCost']?.toDouble() ?? 0.0,
      parentId: json['parentId'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pbuckCost': pbuckCost,
      'parentId': parentId,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 