class Task {
  final String title;
  final String deadline;
  bool done;
  final String priority;

  Task({required this.title, required this.deadline, required this.done, required this.priority});
}

class TaskRepository {
  static List<Task> tasks = [
    Task(title: "pojsc na silownie", deadline: "pojutrze", done: false, priority: "sredni"),
    Task(title: "oddac zadanie laboratoryjne", deadline: "wczoraj", done: true, priority: "niski"),
    Task(title: "zdobyc certyfikat cisco", deadline: "przedwczoraj", done: true, priority: "wysoki"),
    Task(title: "odnowic fizyczna karte kredytowa", deadline: "za 3 lata", done: false, priority: "wysoki"),
  ];
}

