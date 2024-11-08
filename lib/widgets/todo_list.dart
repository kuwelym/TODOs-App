import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoList extends StatefulWidget {
  final List<Map<String, dynamic>> todos;
  final String filter;
  final Function(int) markTodoAsCompleted;

  const TodoList(
      {super.key,
        required this.todos,
        required this.filter,
        required this.markTodoAsCompleted});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final Map<int, bool> _checkboxStates = {};
  bool _isCompletedTodayExpanded = false;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> filteredTodos = widget.todos.where((todo) {
      if (widget.filter == 'Today') {
        return todo['dueTime'].day == now.day &&
            todo['dueTime'].month == now.month &&
            todo['dueTime'].year == now.year &&
            !todo['isCompleted'];
      } else if (widget.filter == 'Upcoming') {
        return todo['dueTime'].isAfter(now) && !todo['isCompleted'];
      }
      return !todo['isCompleted'];
    }).toList();

    List<Map<String, dynamic>> completedTodayTodos = widget.todos.where((todo) {
      if (todo['completedDate'] == null) return false;
      DateTime completedDate = DateTime.parse(todo['completedDate']);
      return completedDate.day == now.day &&
          completedDate.month == now.month &&
          completedDate.year == now.year;
    }).toList();

    return ListView(
      children: [
        ...filteredTodos.map((todo) {
          var dueTime = DateFormat('dd/MM/yyyy HH:mm').format(todo['dueTime']);
          bool isChecked =
              _checkboxStates[todo.hashCode] ?? todo['isCompleted'];

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
                    widget.markTodoAsCompleted(widget.todos.indexOf(todo));
                  });
                });
              },
            ),
          );
        }),
        if (completedTodayTodos.isNotEmpty)
          ExpansionTile(
            title: const Text(
              'Completed Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: _isCompletedTodayExpanded,
            onExpansionChanged: (bool expanded) {
              setState(() {
                _isCompletedTodayExpanded = expanded;
              });
            },
            children: completedTodayTodos.map((todo) {
              var dueTime =
              DateFormat('dd/MM/yyyy HH:mm').format(todo['dueTime']);
              return ListTile(
                title: Text(todo['title']),
                subtitle: Text('Due: $dueTime'),
                trailing: const Icon(Icons.check, color: Colors.green),
              );
            }).toList(),
          ),
      ],
    );
  }
}