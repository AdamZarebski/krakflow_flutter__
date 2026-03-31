import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  List<Task> tasks = [
    Task(title: "pojsc na silownie", deadline: "pojutrze", done: false, priority: "sredni"),
    Task(title: "oddac zadanie laboratoryjne", deadline: "wczoraj", done: true, priority: "niski"),
    Task(title: "zdobyc certyfikat cisco", deadline: "przedwczoraj", done: true, priority: "wysoki"),
    Task(title: "odnowic fizyczna karte kredytowa", deadline: "za 3 lata", done: false, priority: "wysoki"),
  ];

  @override
  Widget build(BuildContext context) {

    int completedCount = tasks.where((t) => t.done).length;

    return MaterialApp(
      home: Scaffold(
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
                    "Masz dzisiaj ${tasks.length} zadania, wykonano: $completedCount",
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
              for (var task in tasks)
                TaskCard(
                  title: task.title,
                  subtitle: "termin: ${task.deadline} \npriorytet: ${task.priority}",
                  icon: task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                ),
            ],
          )
      ),
    );
  }
}
class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({required this.title, required this.deadline, required this.done, required this.priority});
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