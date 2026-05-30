import 'package:flutter/material.dart';
import 'package:krakflow/services/TaskLocalDatabase.dart';
import 'TaskRepository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:krakflow/models/task.dart';
//import '../services/task_api_service.dart';
import 'dart:math';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../services/TaskApiService.dart';
import '../services/TaskSyncService.dart';
import 'dart:developer' as developer;


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("tasks");

  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter",
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int allTasksCount = 0;
  int doneTasksCount = 0;
  int todoTasksCount = 0;

  bool _isInitialised = false;
  late Future<void> _initSyncFuture;

  @override
  void initState() {
    super.initState();
    _initSyncFuture = TaskSyncService.loadInitialDataIfNeeded();
  }

  void updateCounters(List<Task> tasks) {
    setState(() {
      allTasksCount = tasks.length;
      doneTasksCount = tasks.where((task) => task.done).length;
      todoTasksCount = tasks.where((task) => !task.done).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initSyncFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isInitialised) {
            return const Center(child: CircularProgressIndicator());
          }
          _isInitialised = true;

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Masz dzisiaj $allTasksCount zadań, wykonano: $doneTasksCount",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: MojEkranAplikacji(
                    onTasksLoaded: updateCounters,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

   TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19,
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }

}

class MojEkranAplikacji extends StatefulWidget {

  final ValueChanged<List<Task>> onTasksLoaded;
  const MojEkranAplikacji({super.key, required this.onTasksLoaded});

  @override
  State<MojEkranAplikacji> createState() => StanDynamicznegoWidgetu();

}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: "Tytul zadania",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10,),
          TextField(
            controller: deadlineController,
            decoration: InputDecoration(
              labelText: "Termin zadania",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: priorityController,
            decoration: const InputDecoration(
              labelText: "Priorytet (niski/średni/wysoki)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () {
              final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text.isEmpty ? "niski" : priorityController.text,);
              Navigator.pop(context, newTask);
            },
            child: Text("Zapisz"),
          ),
        ],
      ),
    ),
    );
  }
}

class StanDynamicznegoWidgetu extends State<MojEkranAplikacji> {
  String selectedFilter = "wszystkie";

  late Future<List<Task>> tasksFuture;

  @override
  void initState(){
    super.initState();
    tasksFuture = TaskApiService.fetchTasks();
  }

  Future<List<Task>> loadTasks() async {
    //await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Krakflow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
        body: FutureBuilder<List<Task>>(
            future: tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Błąd: ${snapshot.error}"));
              }

              if (snapshot.hasData) {
                final tasks = snapshot.data!;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onTasksLoaded(tasks);
                });

                List<Task> filteredTasks = tasks;
                if (selectedFilter == "wykonane") {
                  filteredTasks = tasks.where((task) => task.done).toList();
                } else if (selectedFilter == "do zrobienia") {
                  filteredTasks = tasks.where((task) => !task.done).toList();
                }
                int totalCount = tasks.length;
                int completedCount = tasks
                    .where((t) => t.done)
                    .length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Masz dzisiaj $totalCount zadań, wykonano: $completedCount",
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFilterButton("wszystkie"),
                              _buildFilterButton("do zrobienia"),
                              _buildFilterButton("wykonane"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];

                          return Dismissible(
                            key: ObjectKey(task),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                  Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              await TaskLocalDatabase.deleteTask(task.id);
                              setState(() {
                                tasksFuture = loadTasks();

                              });
                            },
                            child: TaskCard(
                              title: task.title,
                              subtitle: "termin: ${task
                                  .deadline} \npriorytet: ${task.priority}",
                              done: task.done,
                              onChanged: (value) async {
                                final updatedTask = Task(
                                  id: task.id,
                                  title: task.title,
                                  deadline: task.deadline,
                                  priority: task.priority,
                                  done: value ?? false,
                                );
                                await TaskLocalDatabase.updateTask(updatedTask);
                                setState(() {
                                  tasksFuture = loadTasks();
                                });
                              },
                              onTap: () async {
                                final Task? updatedTask = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditTaskScreen(task: task),
                                  ),
                                );
                                if (updatedTask != null) {
                                  await TaskLocalDatabase.updateTask(updatedTask);
                                  setState(() {
                                    tasksFuture = loadTasks();
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: Text("Brak zadan"));
            },
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTask != null) {
            await TaskLocalDatabase.addTask(newTask);
            setState(() {
              tasksFuture = loadTasks();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    bool isActive = selectedFilter == label;
    return TextButton(
      onPressed: () => setState(() => selectedFilter = label),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potwierdzenie"),
          content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () async {
                await TaskLocalDatabase.deleteAllTasks();
                setState(() {
                  tasksFuture = loadTasks();
                });
                Navigator.pop(context);
              },
              child: const Text("Usuń", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
class EditTaskScreen extends StatelessWidget {
  final Task task;
  final TextEditingController titleController;
  final TextEditingController deadlineController;

  EditTaskScreen({super.key, required this.task})
      : titleController = TextEditingController(text: task.title),
        deadlineController = TextEditingController(text: task.deadline);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edytuj zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Tytuł zadania", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(labelText: "Termin", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  id: task.id,
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: task.done,
                  priority: task.priority,
                );
                Navigator.pop(context, updatedTask);
              },
              child: Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}