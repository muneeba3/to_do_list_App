import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  final String title;
  final String desc;

  Task(this.title, this.desc);
}

class AddTask extends StatefulWidget {
  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
  List<Task> _tasks = [];

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = _tasks.map((task) => '${task.title};${task.desc}').toList();
    await prefs.setStringList('tasks', taskList);
  }

  void _addTask() async {
    String taskTitle = title.text;
    String taskDescription = desc.text;

    if (taskTitle.isNotEmpty) {
      Task newTask = Task(taskTitle, taskDescription);

      setState(() {
        _tasks.add(newTask);
        title.text = '';
        desc.text = '';
      });

      await _saveTasks(); // Save the new task
      Navigator.pop(context, true); // Notify the main page to refresh
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Task'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: title,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter title',
                prefixIcon: Icon(Icons.text_fields_rounded, color: Colors.red.shade300),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: desc,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter Description',
                prefixIcon: Icon(Icons.description, color: Colors.red.shade300),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addTask();
              },
              child: const Text('ADD'),
            ),
          ],
        ),
      ),
    );
  }
}
