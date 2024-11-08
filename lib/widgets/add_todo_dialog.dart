import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/widgets/add_todo_topbar.dart';

class AddTodoDialog extends StatefulWidget {
  final Function(String, DateTime) onAdd;

  const AddTodoDialog({super.key, required this.onAdd});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDateTime;

  bool get _isAddButtonEnabled => _titleController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {}); // Rebuild to enable/disable add button
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AddTodoTopBar(),
              SafeArea(
                minimum: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      autofocus: false,
                      decoration: const InputDecoration(
                        labelText: 'Input new task here',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DateTimePicker(
                          selectedDateTime: _selectedDateTime,
                          onDateTimeChanged: (DateTime? newDateTime) {
                            setState(() {
                              _selectedDateTime = newDateTime;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AddButton(
                          isEnabled: _isAddButtonEnabled,
                          onPressed: () {
                            widget.onAdd(
                              _titleController.text,
                              _selectedDateTime ?? DateTime.now(),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class DateTimePicker extends StatelessWidget {
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime?> onDateTimeChanged;

  const DateTimePicker({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.blue,
          ),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());


            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                initialTime: TimeOfDay.now(),
                context: context,
              );
              if (pickedTime != null) {
                onDateTimeChanged(DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                ));
              }
            }
          },
        ),
        Text(
          selectedDateTime == null
              ? 'No Date'
              : DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!),
        ),
      ],
    );
  }
}

class AddButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const AddButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      child: const Text('Add'),
    );
  }
}

void showAddTodoBottomSheet(
    BuildContext context, Function(String, DateTime) onAdd) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) => AddTodoDialog(onAdd: onAdd),
  );
}
