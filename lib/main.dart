import 'package:flutter/material.dart';
import 'package:to_do_app/addTask.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  final String title;
  final String description;
  bool isCompleted;
  Task(this.title, this.description, {this.isCompleted = false});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'To Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> _tasks = [];
  String searchQuery = '';
  List<Task> _filteredTasks = [];
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }


  void _addTaskPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTask(),
      ),
    );
    if (result == true) {
      _loadTasks(); // Refresh tasks if a new task was added
    }
  }
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = _tasks.map((task) => '${task.title};${task.description}').toList();
    await prefs.setStringList('tasks', taskList);
  }
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = prefs.getStringList('tasks') ?? [];
    List<Task> loadedTasks = taskList.map((taskString) {
      List<String> parts = taskString.split(';');
      bool isCompleted = parts.length > 2 ? parts[2] == 'true' : false;
      return Task(parts[0], parts[1], isCompleted: isCompleted);
    }).toList();

    setState(() {
      _tasks.addAll(loadedTasks);
      _filteredTasks = _tasks; // Initialize _filteredTasks with all tasks initially
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

           TextField(
             onChanged: (value) {
               setState(() {
                 searchQuery = value.toLowerCase();
                 _filteredTasks = _tasks.where((task) =>
                     task.title.toLowerCase().contains(searchQuery)).toList();
               });
             },
              decoration: InputDecoration(
                  label: Text('search'),
                  prefixIcon: Icon(Icons.search, color: Colors.red.shade300),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: searchQuery.isEmpty ? _tasks.length : _filteredTasks.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final task = searchQuery.isEmpty ? _tasks[index] : _filteredTasks[index];
                return ListTile(
                  title: Text(
                    task.isCompleted
                        ? ' ${task.title}' // Marked as completed
                        : task.title, // Not completed
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough // Add strikethrough if completed
                          : null,
                    ),
                  ),
                  subtitle: Text(task.description),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      setState(() {
                        task.isCompleted = value!;
                        _saveTasks();
                      });
                    },
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      _removeTask(index);
                    },
                    icon: Icon(Icons.delete, color: Colors.red.shade300),
                  ),
                );
              },
            )

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
