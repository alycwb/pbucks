import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'storage_service.dart';

class TaskService {
  final StorageService _storage;
  final _uuid = const Uuid();

  TaskService(this._storage);

  Future<Task> createTask({
    required String title,
    required String description,
    required double pbuckValue,
    required String parentId,
    required List<String> childIds,
    DateTime? dueDate,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      pbuckValue: pbuckValue,
      parentId: parentId,
      childIds: childIds,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    await _storage.saveTask(task);
    return task;
  }

  Future<List<Task>> getTasksForChild(String childId) async {
    final allTasks = await _storage.getTasks();
    return allTasks.where((task) => task.childIds.contains(childId)).toList();
  }

  Future<List<Task>> getTasksForParent(String parentId) async {
    return _storage.getTasksForParent(parentId);
  }

  Future<void> markTaskAsComplete(String taskId, String childId) async {
    final tasks = await _storage.getTasks();
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      final updatedStatuses = Map<String, TaskStatus>.from(task.childStatuses);
      updatedStatuses[childId] = TaskStatus.completed;

      tasks[taskIndex] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        pbuckValue: task.pbuckValue,
        parentId: task.parentId,
        childIds: task.childIds,
        childStatuses: updatedStatuses,
        createdAt: task.createdAt,
      );

      await _storage.saveTask(tasks[taskIndex]);

      final child = await _storage.getUserById(childId);
      if (child != null) {
        final updatedChild = User(
          id: child.id,
          name: child.name,
          email: child.email,
          password: child.password,
          role: child.role,
          parentId: child.parentId,
          pbuckBalance: child.pbuckBalance + task.pbuckValue,
        );
        await _storage.saveUser(updatedChild);
      }
    }
  }

  Future<void> approveTask(Task task, String childId) async {
    final updatedStatuses = Map<String, TaskStatus>.from(task.childStatuses);
    updatedStatuses[childId] = TaskStatus.approved;

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      pbuckValue: task.pbuckValue,
      parentId: task.parentId,
      childIds: task.childIds,
      createdAt: task.createdAt,
      dueDate: task.dueDate,
      status: task.isApprovedForAll ? TaskStatus.approved : task.status,
      proofImageUrl: task.proofImageUrl,
      childStatuses: updatedStatuses,
    );

    await _storage.saveTask(updatedTask);

    final child = await _storage.getUserById(childId);
    if (child != null) {
      final updatedChild = User(
        id: child.id,
        name: child.name,
        email: child.email,
        password: child.password,
        role: child.role,
        parentId: child.parentId,
        pbuckBalance: child.pbuckBalance + task.pbuckValue,
      );
      await _storage.saveUser(updatedChild);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await _storage.getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    if (tasks.isNotEmpty) {
      await _storage.saveTask(tasks.first);
    }
  }
} 