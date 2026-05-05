import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchData() async {
  final response = await http.get(
    Uri.parse("https://dummyjson.com/todos"),
    headers: {
      "Accept": "application/json",
    },
  );
}

