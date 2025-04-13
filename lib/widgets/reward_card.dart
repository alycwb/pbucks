import 'package:flutter/material.dart';
import '../models/reward.dart';
import '../constants/app_theme.dart';

class RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback? onRedeem;
  final bool canAfford;
  final bool isParentView;

  const RewardCard({
    super.key,
    required this.reward,
    this.onRedeem,
    required this.canAfford,
    this.isParentView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reward.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                reward.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reward.title,
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
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${reward.pbuckCost.toInt()} PB',
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
                  reward.description,
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
                    if (!isParentView && reward.status == RewardStatus.available)
                      ElevatedButton(
                        onPressed: canAfford ? onRedeem : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford
                              ? AppTheme.accentColor
                              : Colors.grey[300],
                          foregroundColor:
                              canAfford ? Colors.white : Colors.grey[600],
                        ),
                        child: Text(
                          canAfford ? 'Redeem' : 'Not Enough PBucks',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (reward.status) {
      case RewardStatus.available:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        label = 'Available';
        icon = Icons.check_circle;
        break;
      case RewardStatus.redeemed:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        label = 'Redeemed';
        icon = Icons.redeem;
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