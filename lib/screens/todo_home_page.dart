import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/todo_list.dart';
import '../widgets/add_todo_dialog.dart';
import '../services/notification_service.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _filteredTodos = [];
  final TextEditingController _searchController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initializeNotifications();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosString = prefs.getString('todos');
    if (todosString != null) {
      final loadedTodos = List<Map<String, dynamic>>.from(
        json.decode(todosString).map((todo) {
          todo['dueTime'] = DateTime.parse(todo['dueTime']);
          return todo;
        }),
      );
      setState(() {
        _todos = loadedTodos;
        _filteredTodos = List.from(_todos);
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'todos',
      json.encode(
        _todos.map((todo) => {
          ...todo,
          'dueTime': todo['dueTime'].toIso8601String(),
        }).toList(),
      ),
    );
  }

  void _markTodoAsCompleted(int index) {
    setState(() {
      _todos[index]['isCompleted'] = true;
      _todos[index]['completedDate'] = DateTime.now().toIso8601String();
    });
    _saveTodos();
    _notificationService.cancelNotification(index);
  }

  void _addTodo(String title, DateTime dueTime) {
    final newTodo = {
      'title': title,
      'dueTime': dueTime,
      'isCompleted': false,
    };
    setState(() {
      _todos.add(newTodo);
      _filteredTodos = List.from(_todos);
    });
    _saveTodos();
    if (!_todos.last['isCompleted']) {
      _notificationService.scheduleNotification(_todos.length - 1, dueTime);
    }
  }

  void _filterTodos(String query) {
    setState(() {
      _filteredTodos = query.isEmpty
          ? List.from(_todos)
          : _todos
          .where((todo) => todo['title']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
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
                onChanged: _filterTodos,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTodoList('All'),
                  _buildTodoList('Today'),
                  _buildTodoList('Upcoming'),
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

  Widget _buildTodoList(String filter) {
    return TodoList(
      todos: _filteredTodos,
      filter: filter,
      markTodoAsCompleted: _markTodoAsCompleted,
    );
  }
}
