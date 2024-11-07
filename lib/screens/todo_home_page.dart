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
  List<Map<String, dynamic>> todos = [];
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
      setState(() {
        todos = List<Map<String, dynamic>>.from(
          json.decode(todosString).map((todo) {
            todo['dueTime'] = DateTime.parse(todo['dueTime']);
            return todo;
          }),
        );
        _filteredTodos = todos;
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'todos',
      json.encode(
        todos.map((todo) => {
          ...todo,
          'dueTime': todo['dueTime'].toIso8601String(),
        }).toList(),
      ),
    );
  }

  void _markTodoAsCompleted(int index) {
    setState(() {
      todos[index]['isCompleted'] = true;
    });
    _saveTodos();
  }

  void _addTodo(String title, DateTime dueTime) {
    setState(() {
      todos.add({
        'title': title,
        'dueTime': dueTime,
        'isCompleted': false,
      });
      _filteredTodos = todos;
    });
    _saveTodos();
    if (!todos.last['isCompleted']) {
      _notificationService.scheduleNotification(dueTime);
    }
  }

  void _filterTodos(String query) {
    setState(() {
      _filteredTodos = query.isEmpty
          ? todos
          : todos.where((todo) => todo['title'].toLowerCase().contains(query.toLowerCase())).toList();
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
                  TodoList(
                    todos: _filteredTodos,
                    filter: 'All',
                    markTodoAsCompleted: _markTodoAsCompleted,
                  ),
                  TodoList(
                    todos: _filteredTodos,
                    filter: 'Today',
                    markTodoAsCompleted: _markTodoAsCompleted,
                  ),
                  TodoList(
                    todos: _filteredTodos,
                    filter: 'Upcoming',
                    markTodoAsCompleted: _markTodoAsCompleted,
                  ),
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
