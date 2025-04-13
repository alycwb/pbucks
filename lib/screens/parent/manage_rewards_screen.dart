import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reward.dart';
import '../../models/user.dart';
import '../../services/reward_service.dart';
import '../../services/storage_service.dart';

class ManageRewardsScreen extends StatefulWidget {
  const ManageRewardsScreen({super.key});

  @override
  State<ManageRewardsScreen> createState() => _ManageRewardsScreenState();
}

class _ManageRewardsScreenState extends State<ManageRewardsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pbuckCostController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pbuckCostController.dispose();
    super.dispose();
  }

  void _showAddRewardDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Reward',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Reward Title',
                              prefixIcon: Icon(Icons.card_giftcard),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _pbuckCostController,
                            decoration: const InputDecoration(
                              labelText: 'PBucks Cost',
                              prefixIcon: Icon(Icons.monetization_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a cost';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearForm();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final rewardService = Provider.of<RewardService>(context, listen: false);
                          final currentUser = await Provider.of<StorageService>(context, listen: false).getCurrentUser();
                          
                          if (currentUser != null) {
                            await rewardService.createReward(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              pbuckCost: double.parse(_pbuckCostController.text),
                              parentId: currentUser.id,
                            );
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              _clearForm();
                              setState(() {}); // Refresh the list
                            }
                          }
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _pbuckCostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rewards'),
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

          return FutureBuilder<List<Reward>>(
            future: Provider.of<RewardService>(context).getRewardsForParent(userSnapshot.data!.id),
            builder: (context, rewardSnapshot) {
              if (rewardSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final rewards = rewardSnapshot.data ?? [];

              if (rewards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No rewards created yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddRewardDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Reward'),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      return Card(
                        child: ListTile(
                          leading: Container(
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
                          title: Text(reward.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reward.description),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    reward.isAvailable ? Icons.check_circle : Icons.cancel,
                                    size: 16,
                                    color: reward.isAvailable ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reward.isAvailable ? 'Available' : 'Not Available',
                                    style: TextStyle(
                                      color: reward.isAvailable ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${reward.pbuckCost.toInt()} PB',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            // Toggle reward availability
                            Provider.of<RewardService>(context, listen: false)
                                .toggleRewardAvailability(reward.id)
                                .then((_) => setState(() {}));
                          },
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: _showAddRewardDialog,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 