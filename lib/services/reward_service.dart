import 'dart:convert';
import '../models/reward.dart';
import 'storage_service.dart';
import 'package:uuid/uuid.dart';

class RewardService {
  static const String _rewardsKey = 'rewards';
  final _uuid = const Uuid();
  final StorageService _storage;

  RewardService(this._storage);

  Future<List<Reward>> getRewardsForParent(String parentId) async {
    final rewardsJson = await _storage.getString(_rewardsKey);
    if (rewardsJson == null) return [];

    final List<dynamic> rewardsList = jsonDecode(rewardsJson);
    return rewardsList
        .map((json) => Reward.fromJson(json))
        .where((reward) => reward.parentId == parentId)
        .toList();
  }

  Future<List<Reward>> getAvailableRewardsForParent(String parentId) async {
    final rewards = await getRewardsForParent(parentId);
    return rewards.where((reward) => reward.isAvailable).toList();
  }

  Future<Reward> createReward({
    required String title,
    required String description,
    required double pbuckCost,
    required String parentId,
  }) async {
    final reward = Reward(
      id: _uuid.v4(),
      title: title,
      description: description,
      pbuckCost: pbuckCost,
      parentId: parentId,
      createdAt: DateTime.now(),
    );

    final List<Reward> rewards = await _getAllRewards();
    rewards.add(reward);
    await _saveRewards(rewards);

    return reward;
  }

  Future<bool> canAffordReward(String userId, Reward reward) async {
    final user = await _storage.getUserById(userId);
    return user != null && user.pbuckBalance >= reward.pbuckCost;
  }

  Future<void> redeemReward(String userId, String rewardId) async {
    // TODO: Implement reward redemption
  }

  Future<void> toggleRewardAvailability(String rewardId) async {
    final rewards = await _getAllRewards();
    final rewardIndex = rewards.indexWhere((r) => r.id == rewardId);
    
    if (rewardIndex != -1) {
      final reward = rewards[rewardIndex];
      rewards[rewardIndex] = Reward(
        id: reward.id,
        title: reward.title,
        description: reward.description,
        pbuckCost: reward.pbuckCost,
        parentId: reward.parentId,
        isAvailable: !reward.isAvailable,
        createdAt: reward.createdAt,
      );
      await _saveRewards(rewards);
    }
  }

  Future<void> deleteReward(String rewardId) async {
    final rewards = await _getAllRewards();
    rewards.removeWhere((reward) => reward.id == rewardId);
    await _saveRewards(rewards);
  }

  Future<List<Reward>> _getAllRewards() async {
    final rewardsJson = await _storage.getString(_rewardsKey);
    if (rewardsJson == null) return [];

    final List<dynamic> rewardsList = jsonDecode(rewardsJson);
    return rewardsList.map((json) => Reward.fromJson(json)).toList();
  }

  Future<void> _saveRewards(List<Reward> rewards) async {
    await _storage.setString(
      _rewardsKey,
      jsonEncode(rewards.map((reward) => reward.toJson()).toList()),
    );
  }
} 