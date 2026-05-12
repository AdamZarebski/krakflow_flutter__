class Task {
  final int id;
  final String title;
  final String deadline;
  bool done;
  final String priority;

  Task({required this.id, required this.title, required this.deadline, required this.done, required this.priority});

  Map<String, dynamic> toMap(){
    return {
      "id" : id,
      "title" : title,
      "deadline" : deadline,
      "done" : done,
      "priority" : priority,
    };
  }

  factory Task.fromMap(Map map){
    return Task(
      id : map["id"],
      title : map["title"],
      deadline : map["deadline"],
      done : map["done"],
      priority : map["id"],
    );
  }
}

class TaskRepository {
  static List<Task> tasks = [
    Task(id: 1, title: "pojsc na silownie", deadline: "pojutrze", done: false, priority: "sredni"),
    Task(id: 2, title: "oddac zadanie laboratoryjne", deadline: "wczoraj", done: true, priority: "niski"),
    Task(id: 3, title: "zdobyc certyfikat cisco", deadline: "przedwczoraj", done: true, priority: "wysoki"),
    Task(id: 4, title: "odnowic fizyczna karte kredytowa", deadline: "za 3 lata", done: false, priority: "wysoki"),
  ];
}

