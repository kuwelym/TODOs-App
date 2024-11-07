import 'package:flutter/material.dart';

class AddTodoTopBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const AddTodoTopBar ({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('Add Task',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }
}
