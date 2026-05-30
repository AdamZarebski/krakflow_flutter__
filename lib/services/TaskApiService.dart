import '../models/TaskRepository.dart';
import 'TaskLocalDatabase.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:developer' as developer;

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";
  //static const String baseUrl = "https://dummyjson.com/dfabsf";//endpoint debug
  static Future<List<Task>> fetchTasks() async {
    const String url = "$baseUrl/todos";
    developer.log("Wysylanie zapytania pod adres: $url", name: "TaskApiService");

    final response = await http.get(
      Uri.parse(url),
    );
    developer.log("Kod odpowiedzi HTTP: ${response.statusCode}", name: "TaskApiService");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];
      developer.log("Pomyslnie pobrano zadania, liczba zadan: ${todos.length}", name: "TaskApiService");
      return todos.map((todo) {
        final random = Random();
        final priorities = ["niski", "średni", "wysoki"];
        final priority = priorities[random.nextInt(priorities.length)];
        final deadlines = ["jutro", "za miesiac", "za rok", "pojutrze"];
        final deadline = deadlines[random.nextInt(deadlines.length)];

        return Task(
          id : todo["id"],
          title: todo["todo"],
          deadline: deadline,
          done: todo["completed"],
          priority: priority,
        );
      }).toList();
    } else {
      developer.log("Blad pobierania danych, status odpowiedzi: ${response.statusCode}", name: "TaskApiService", error: response.body);
      throw Exception("Błąd pobierania danych");
    }
  }
}
