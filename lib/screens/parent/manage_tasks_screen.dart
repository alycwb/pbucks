import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../services/storage_service.dart';

class ManageTasksScreen extends StatefulWidget {
  const ManageTasksScreen({super.key});

  @override
  State<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pbuckValueController = TextEditingController();
  Set<String> _selectedChildIds = {};
  bool _assignToAllChildren = true;
  bool _isChildrenDropdownOpen = false;  // New field to control dropdown state

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pbuckValueController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog(List<User> children) {
    // Reset selections when opening dialog
    setState(() {
      _selectedChildIds = {};
      _assignToAllChildren = true;  // Reset to true when opening dialog
    });

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600, // Make dialog wider
              maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit max height
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Task Title',
                                    prefixIcon: Icon(Icons.task),
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
                                  controller: _pbuckValueController,
                                  decoration: const InputDecoration(
                                    labelText: 'PBucks Value',
                                    prefixIcon: Icon(Icons.monetization_on),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a value';
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
                          const SizedBox(height: 24),
                          CheckboxListTile(
                            title: const Text(
                              'Assign to all children',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: _assignToAllChildren,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                _assignToAllChildren = value ?? false;
                                if (_assignToAllChildren) {
                                  _selectedChildIds.clear();
                                }
                              });
                            },
                          ),
                          if (!_assignToAllChildren) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Select specific children:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${_selectedChildIds.length} selected)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PopupMenuButton<String>(
                                onOpened: () => setDialogState(() => _isChildrenDropdownOpen = true),
                                onCanceled: () => setDialogState(() => _isChildrenDropdownOpen = false),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                                ),
                                position: PopupMenuPosition.under,
                                itemBuilder: (context) => [
                                  ...children.map((child) => PopupMenuItem<String>(
                                    value: child.id,
                                    child: StatefulBuilder(
                                      builder: (context, setState) => CheckboxListTile(
                                        title: Text(child.name),
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: Theme.of(context).primaryColor,
                                        value: _selectedChildIds.contains(child.id),
                                        onChanged: (bool? value) {
                                          setDialogState(() {
                                            if (value == true) {
                                              _selectedChildIds.add(child.id);
                                            } else {
                                              _selectedChildIds.remove(child.id);
                                            }
                                          });
                                          setState(() {});  // Update checkbox state
                                        },
                                        controlAffinity: ListTileControlAffinity.leading,
                                      ),
                                    ),
                                  )),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedChildIds.isEmpty
                                              ? 'Select children...'
                                              : '${_selectedChildIds.length} children selected',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        _isChildrenDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
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
                            if (!_assignToAllChildren && _selectedChildIds.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select at least one child'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final taskService = Provider.of<TaskService>(context, listen: false);
                            final currentUser = await Provider.of<StorageService>(context, listen: false).getCurrentUser();
                            
                            if (currentUser != null) {
                              final List<String> targetChildIds = _assignToAllChildren
                                  ? children.map((c) => c.id).toList()
                                  : _selectedChildIds.toList();

                              await taskService.createTask(
                                title: _titleController.text,
                                description: _descriptionController.text,
                                pbuckValue: double.parse(_pbuckValueController.text),
                                parentId: currentUser.id,
                                childIds: targetChildIds,
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
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _pbuckValueController.clear();
    _selectedChildIds.clear();
    _assignToAllChildren = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
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

          return FutureBuilder<List<Task>>(
            future: Provider.of<TaskService>(context).getTasksForParent(userSnapshot.data!.id),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = taskSnapshot.data ?? [];

              return FutureBuilder<List<User>>(
                future: Provider.of<StorageService>(context).getChildrenForParent(userSnapshot.data!.id),
                builder: (context, childrenSnapshot) {
                  if (childrenSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final children = childrenSnapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No tasks created yet',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          if (children.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () => _showAddTaskDialog(children),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Task'),
                            )
                          else
                            const Text(
                              'Add children first to create tasks',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final assignedChildren = children.where(
                            (child) => task.childIds.contains(child.id)
                          ).toList();

                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
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
                                  title: Text(task.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(task.description),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            'Assigned to: ',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: Text(
                                              task.childIds.length == children.length
                                                  ? 'All children'
                                                  : task.childIds
                                                      .map((childId) => children
                                                          .firstWhere((c) => c.id == childId)
                                                          .name)
                                                      .join(', '),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    '${task.pbuckValue.toInt()} PB',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (children.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            onPressed: () => _showAddTaskDialog(children),
                            child: const Icon(Icons.add),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 