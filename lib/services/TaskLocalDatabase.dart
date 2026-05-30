import 'package:hive_ce/hive.dart';
import '../models/TaskRepository.dart';
import 'dart:developer' as developer;

class TaskLocalDatabase {

  static Box get _box => Hive.box("tasks");
  static List<Task> getTasks() {

    return _box.values.map((item) {
      return Task.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    await _box.clear();

    for (final task in tasks) {
      await _box.put(task.id, task.toMap());
    }
    developer.log("Zapisano nowa liste zadan do bazy Hive (Synchronizacja z API)", name: "TaskLocalDatabase");
  }
  static Future<void> addTask(Task task) async {
    await _box.put(task.id, task.toMap());
    developer.log("Dodano nowe zadanie do bazy. ID: ${task.id}, Tytuł: ${task.title}", name: "TaskLocalDatabase");
  }
  static Future<void> updateTask(Task task) async {
    final oldData = _box.get(task.id);
    if (oldData != null) {
      final oldTask = Task.fromMap(Map<String, dynamic>.from(oldData));

      if (oldTask.done != task.done) {
        developer.log("Zmieniono status wykonania zadania o ID: ${task.id} na: ${task.done ? 'WYKONANE' : 'DO ZROBIENIA'}", name: "TaskLocalDatabase");
      } else {
        developer.log("Edytowano zawartość zadania o ID: ${task.id} (Tytuł/Termin)", name: "TaskLocalDatabase");
      }
    }

    await _box.put(task.id, task.toMap());
  }

  static Future<void> deleteTask(int id) async {

    await _box.delete(id);
    developer.log("Usunięto z bazy pojedyncze zadanie o ID: $id", name: "TaskLocalDatabase");
  }
  static Future<void> deleteAllTasks() async {
    await _box.clear();
    developer.log("Wyczyszczono lokalną bazę danych. Usunięto wszystkie zadania.", name: "TaskLocalDatabase");
  }
  static bool isEmpty() {
    return _box.isEmpty;
  }
}