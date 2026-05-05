import 'package:flutter/material.dart';
import 'TaskRepository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:krakflow/models/task.dart';
//import '../services/task_api_service.dart';
import 'dart:math';

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";
  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse("$baseUrl/todos"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];
      return todos.map((todo) {
        final random = Random();
        final priorities = ["niski", "średni", "wysoki"];
        final priority = priorities[random.nextInt(priorities.length)];
        final deadlines = ["jutro", "za miesiac", "za rok", "pojutrze"];
        final deadline = deadlines[random.nextInt(deadlines.length)];

        return Task(

          title: todo["todo"],
          deadline: deadline, // brak w API → mockujemy
          done: todo["completed"],
          priority: priority, // brak w API → mockujemy
        );
      }).toList();
    } else {
      throw Exception("Błąd pobierania danych");
    }
  }
}




void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter",
      home: MojEkranAplikacji()
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
  const MojEkranAplikacji({super.key});
  @override
  State<MojEkranAplikacji> createState() => StanDynamicznegoWidgetu();

}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

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

          ElevatedButton(
            onPressed: () {
              final newTask = Task(title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: "niskie");
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

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = TaskRepository.tasks;

    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((task) => !task.done).toList();
    }

    int completedCount = TaskRepository.tasks.where((t) => t.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Krakflow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: TaskRepository.tasks.isEmpty
                ? null
                : () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Masz dzisiaj ${TaskRepository.tasks.length} zadań, wykonano: $completedCount",
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
                  key: ValueKey(task.title),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      TaskRepository.tasks.remove(task);
                    });
                  },
                  child: TaskCard(
                    title: task.title,
                    subtitle: "termin: ${task.deadline} \npriorytet: ${task.priority}",
                    done: task.done,
                    onChanged: (value) {
                      setState(() {
                        task.done = value!;
                      });
                    },
                    onTap: () async {
                      final Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                      if (updatedTask != null) {
                        setState(() {
                          int originalIndex = TaskRepository.tasks.indexOf(task);
                          TaskRepository.tasks[originalIndex] = updatedTask;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
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
              onPressed: () {
                setState(() {
                  TaskRepository.tasks.clear();
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