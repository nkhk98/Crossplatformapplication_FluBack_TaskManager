import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// 1. BACK4APP MODEL DEFINITION (Copied from previous solution)
class Task extends ParseObject implements ParseCloneable {
  Task() : super('Task');
  Task.clone() : this();

  @override
  Task clone(Map<String, dynamic> map) => Task.clone()..fromJson(map);

  String? get title =>
      get('title'); // Matches the 'text' field used in your UI logic
  set title(String? value) => set('title', value);

  // NOTE: You'd want to add 'description' and 'isDone' fields here too,
  // but for simplicity, we only use 'title' to map to your existing 'text' field.
}

// 2. MAIN WIDGET - Renamed and adapted
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Use List<ParseObject> instead of List<Note>
  final List<Task> _items = [];
  late QueryBuilder<Task> _taskQuery; // Query to filter tasks by current user

  @override
  void initState() {
    super.initState();
    _initializeTaskQuery();
    _loadTasksFromBack4App(); // Changed name from _loadNotesFromDb
  }

  Future<void> _initializeTaskQuery() async {
    final currentUser = await ParseUser.currentUser();
    // Setup query to only fetch tasks linked to the currently logged-in user
    _taskQuery = QueryBuilder<Task>(Task())
      ..whereEqualTo('user', currentUser)
      ..orderByDescending('createdAt');
  }

  // C.R.U.D. Logic ----------------------------------------------------

  // READ (R) operation
  Future<void> _loadTasksFromBack4App() async {
    await _initializeTaskQuery();
    final response = await _taskQuery.query();

    if (response.success && response.results != null) {
      final tasks = response.results!.cast<Task>();
      setState(() {
        _items
          ..clear()
          ..addAll(tasks);
      });
    } else {
      // Handle error case (e.g., show a snackbar)
      _showSnackBar(
        'Failed to load tasks: ${response.error?.message}',
        isError: true,
      );
    }
  }

  // CREATE (C) operation
  Future<void> _addItem(String text) async {
    final currentUser = await ParseUser.currentUser();
    if (currentUser == null) return;

    final task = Task()
      ..title = text
      ..set('user', currentUser) // Link the task to the creator
      ..set('isDone', false); // Assuming tasks start as incomplete

    final response = await task.save();

    if (response.success && response.results != null) {
      final savedTask = response.results!.first as Task;
      setState(() => _items.insert(0, savedTask));
    } else {
      _showSnackBar(
        'Failed to save task: ${response.error?.message}',
        isError: true,
      );
    }
  }

  // UPDATE (U) operation
  Future<void> _updateItem(int index, String newText) async {
    final existing = _items[index];
    existing.title = newText;

    final response = await existing.save();

    if (response.success) {
      // Data updated successfully on server, now update local list
      setState(() => _items[index] = existing);
    } else {
      _showSnackBar(
        'Failed to update task: ${response.error?.message}',
        isError: true,
      );
    }
  }

  // DELETE (D) operation
  Future<void> _removeItem(int index) async {
    final removed = _items[index];

    // Optimistic removal from list
    setState(() => _items.removeAt(index));

    final response = await removed.delete();

    if (!response.success) {
      // If server delete fails, re-insert locally and notify user
      setState(() => _items.insert(index, removed));
      _showSnackBar(
        'Failed to delete task: ${response.error?.message}',
        isError: true,
      );
    } else {
      // Show Snackbar with UNDO logic (re-insert)
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${removed.title}"'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              // Re-save the task to Back4App
              final reResponse = await removed.save();
              if (reResponse.success) {
                // Re-insert the new object from the server into the local list
                final reInserted = reResponse.results!.first as Task;
                setState(() => _items.insert(index, reInserted));
              } else {
                _showSnackBar(
                  'UNDO failed: ${reResponse.error?.message}',
                  isError: true,
                );
                _loadTasksFromBack4App(); // Reload to sync
              }
            },
          ),
        ),
      );
    }
  }

  // Helper for Snackbars
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Dialog remains largely the same, but calls _addItem or _updateItem
  Future<void> _showAddEditDialog({int? index}) async {
    final controller = TextEditingController(
      text: index == null ? '' : _items[index].title, // Use task.title
    );
    final title = index == null ? 'Add New Task' : 'Edit Task';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.deepOrange,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Type a short task description',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context, text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (index == null) {
        await _addItem(result);
      } else {
        await _updateItem(index, result);
      }
    }
  }

  // Method for Secure Logout
  Future<void> _handleLogout() async {
    final user = await ParseUser.currentUser();
    await user?.logout();
    // Navigate back to the Login screen
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FluBack Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5B4), Color(0xFFFFD580), Color(0xFFFFCBA4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _items.isEmpty
            ? const Center(
                child: Text(
                  'No tasks yet. Press + to add.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final task = _items[i];
                  final createdAt =
                      task.get<DateTime>('createdAt') ??
                      DateTime.now(); // Get createdAt from ParseObject

                  return Dismissible(
                    key: ValueKey(task.objectId ?? createdAt.toIso8601String()),
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (_) => _removeItem(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100,
                            Colors.orange.shade200,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.task_alt, // Changed to a task-related icon
                          color: Colors.black54,
                          size: 26,
                        ),
                        title: Text(
                          task.title ?? 'No Title', // Use task.title
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Created: ${createdAt.toLocal().toString().substring(0, 16)}', // Use createdAt
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        onTap: () => _showAddEditDialog(index: i),
                        trailing: Checkbox(
                          value: task.get<bool>('isDone') ?? false,
                          onChanged: (bool? value) {
                            // Simple update for the task status
                            task.set('isDone', value);
                            task.save().then((_) => setState(() {}));
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
