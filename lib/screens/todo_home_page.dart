import 'package:flutter/material.dart';
import '../../widgets/todo_list.dart';
import '../../widgets/add_todo_dialog.dart';
import '../../services/notification_service.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<Map<String, dynamic>> todos = [];
  final TextEditingController _searchController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initializeNotifications();
  }

  void _addTodo(String title, DateTime dueTime) {
    setState(() {
      todos.add({'title': title, 'dueTime': dueTime, 'isCompleted': false});
    });
    _notificationService.scheduleNotification(dueTime);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TODO List'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search TODOs',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TodoList(todos: todos, filter: 'All'),
                  TodoList(todos: todos, filter: 'Today'),
                  TodoList(todos: todos, filter: 'Upcoming'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showAddTodoBottomSheet(context, _addTodo),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}