import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/reward.dart';
import '../../models/user.dart';
import '../../widgets/reward_card.dart';

class StoreScreen extends StatefulWidget {
  final User user;
  final bool isParentView;

  const StoreScreen({
    super.key,
    required this.user,
    this.isParentView = false,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Store'),
        actions: [
          if (!widget.isParentView)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${widget.user.pbuckBalance.toInt()} PB',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildRewardsList(),
      floatingActionButton: widget.isParentView
          ? FloatingActionButton(
              onPressed: _showAddRewardDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRewardsList() {
    // TODO: Replace with actual reward data
    final List<Reward> rewards = [];

    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.isParentView
                  ? 'No rewards added yet!'
                  : 'No rewards available!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isParentView
                  ? 'Add rewards for your children'
                  : 'Check back later for new rewards',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return RewardCard(
          reward: reward,
          canAfford: widget.user.pbuckBalance >= reward.pbuckCost,
          isParentView: widget.isParentView,
          onRedeem: () => _handleRewardRedemption(reward),
        );
      },
    );
  }

  void _showAddRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reward Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'PBucks Cost',
                prefixText: 'PB ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Image URL (Optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement reward creation
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _handleRewardRedemption(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to redeem "${reward.title}"?'),
            const SizedBox(height: 16),
            Text(
              'Cost: ${reward.pbuckCost.toInt()} PB',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your balance: ${widget.user.pbuckBalance.toInt()} PB',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement reward redemption
              Navigator.pop(context);
              _showRedemptionSuccessDialog(reward);
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  void _showRedemptionSuccessDialog(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: AppTheme.secondaryColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve redeemed "${reward.title}"!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Show this to your parent to claim your reward.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 