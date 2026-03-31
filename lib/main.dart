import 'package:flutter/material.dart';
import 'TaskRepository.dart';



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
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
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

class StanDynamicznegoWidgetu extends State<MojEkranAplikacji>{

  int completedCount = TaskRepository.tasks.where((t) => t.done).length;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Krakflow"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  "Masz dzisiaj ${TaskRepository.tasks.length} zadania, wykonano: $completedCount",
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Dzisiejsze zadania",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),


            const SizedBox(height: 16),
            for (var task in TaskRepository.tasks)
              TaskCard(
                title: task.title,
                subtitle: "termin: ${task.deadline} \npriorytet: ${task.priority}",
                icon: task.done ? Icons.check_circle : Icons.radio_button_unchecked,
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final Task? newTask = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddTaskScreen()),
                );
            if (newTask != null){
              setState(() {
                TaskRepository.tasks.add(newTask);
              });
            }

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(),
                )
            );
          },
          child: Icon(Icons.add),
        )
    );
  }

}