import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/task_service.dart';
import '../../services/reward_service.dart';
import '../../models/task.dart';
import '../../models/reward.dart';

class ChildDashboard extends StatefulWidget {
  const ChildDashboard({super.key});

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: Provider.of<StorageService>(context).getCurrentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Please log in again'));
          }

          final user = userSnapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user.name}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber),
                              const SizedBox(width: 8),
                              FutureBuilder<User?>(
                                future: Provider.of<StorageService>(context).getUserById(user.id),
                                builder: (context, updatedUserSnapshot) {
                                  final updatedUser = updatedUserSnapshot.data ?? user;
                                  return Text(
                                    '${updatedUser.pbuckBalance.toInt()} PBucks',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: FutureBuilder<List<Task>>(
                      future: Provider.of<TaskService>(context).getTasksForChild(user.id),
                      builder: (context, taskSnapshot) {
                        if (taskSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final tasks = taskSnapshot.data ?? [];

                        if (tasks.isEmpty) {
                          return const Center(
                            child: Text(
                              'No tasks assigned yet',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final status = task.childStatuses[user.id] ?? TaskStatus.pending;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.task,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(task.description),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                status == TaskStatus.approved
                                                    ? Icons.check_circle
                                                    : status == TaskStatus.completed
                                                        ? Icons.check_circle_outline
                                                        : Icons.radio_button_unchecked,
                                                size: 16,
                                                color: status == TaskStatus.approved
                                                    ? Colors.green
                                                    : status == TaskStatus.completed
                                                        ? Colors.orange
                                                        : Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                status.toString().split('.').last,
                                                style: TextStyle(
                                                  color: status == TaskStatus.approved
                                                      ? Colors.green
                                                      : status == TaskStatus.completed
                                                          ? Colors.orange
                                                          : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${task.pbuckValue.toInt()} PB',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (status == TaskStatus.pending)
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                minimumSize: const Size(60, 30),
                                              ),
                                              onPressed: () async {
                                                await Provider.of<TaskService>(context, listen: false)
                                                    .markTaskAsComplete(task.id, user.id);
                                                
                                                if (context.mounted) {
                                                  setState(() {});
                                                }
                                              },
                                              child: const Text('Complete'),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Available Rewards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: FutureBuilder<List<Reward>>(
                      future: Provider.of<RewardService>(context).getAvailableRewardsForParent(user.parentId!),
                      builder: (context, rewardSnapshot) {
                        if (rewardSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final rewards = rewardSnapshot.data ?? [];

                        if (rewards.isEmpty) {
                          return const Center(
                            child: Text(
                              'No rewards available',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: rewards.length,
                          itemBuilder: (context, index) {
                            final reward = rewards[index];
                            final canAfford = user.pbuckBalance >= reward.pbuckCost;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.card_giftcard,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reward.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(reward.description),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${reward.pbuckCost.toInt()} PB',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (canAfford)
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                minimumSize: const Size(60, 30),
                                              ),
                                              onPressed: () {
                                                // TODO: Implement reward redemption
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Coming soon!'),
                                                  ),
                                                );
                                              },
                                              child: const Text('Redeem'),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 