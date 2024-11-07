import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoList extends StatefulWidget {
  final List<Map<String, dynamic>> todos;
  final String filter;
  final Function(int) markTodoAsCompleted;

  const TodoList({super.key, required this.todos, required this.filter, required this.markTodoAsCompleted});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final Map<int, bool> _checkboxStates = {};

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

        bool isChecked = _checkboxStates[todo.hashCode] ?? todo['isCompleted'];

        return ListTile(
          title: Text(todo['title']),
          subtitle: Text('Due: $dueTime'),
          trailing: Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                _checkboxStates[todo.hashCode] = value!;
              });

              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  todo['isCompleted'] = value;
                  _checkboxStates.remove(todo.hashCode);
                  widget.markTodoAsCompleted(index);
                });
              });
            },
          ),
        );
      },
    );
  }
}
