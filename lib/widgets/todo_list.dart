import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoList extends StatefulWidget {
  final List<Map<String, dynamic>> todos;
  final String filter;

  const TodoList({super.key, required this.todos, required this.filter});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTodos = widget.todos.where((todo) {
      if (widget.filter == 'Today') {
        return todo['dueTime'].day == DateTime.now().day && !todo['isCompleted'];
      } else if (widget.filter == 'Upcoming') {
        return todo['dueTime'].isAfter(DateTime.now()) && !todo['isCompleted'];
      }
      return !todo['isCompleted'];
    }).toList();


    return ListView.builder(
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        var todo = filteredTodos[index];
        var dueTime = DateFormat('dd/MM/yyyy HH:mm').format(todo['dueTime']);
        return ListTile(
          title: Text(todo['title']),
          subtitle: Text('Due: $dueTime'),
          trailing: Checkbox(
            value: todo['isCompleted'],
            onChanged: (bool? value) {
              setState(() {
                todo['isCompleted'] = value!;
              });
            },
          ),
        );
      },
    );
  }
}