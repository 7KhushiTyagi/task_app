import 'dart:convert';
import 'package:frontend/core/constants.dart';
import 'package:frontend/core/utils.dart';
import 'package:frontend/home/repository/task_local_repository.dart';
import 'package:frontend/model/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';


class TaskRemoteRepository {
  final taskLocalRepository = TaskLocalRepository();

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String hexColor,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      final res = await http.post(Uri.parse("${Constants.backendUri}/tasks"),
          headers: {
            'Content-Type': 'application.json',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'title': title,
            'description': description,
            'hexColor': hexColor,
            'dueAt': dueAt.toIso8601String(),
          }));

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }
      return TaskModel.fromJson(res.body);
    } catch (e) {
      try {
        final taskModel = TaskModel(
          id: const Uuid().v4(),
          uid: uid,
          title: title,
          color: hexToColor(hexColor),
          description: description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          isSynced: 0,
        );

        taskLocalRepository.inserTask(taskModel);
        return taskModel;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel?>> getTask({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application.json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final listOfTasks = jsonDecode(res.body);
      final List<TaskModel> taskList = [];

      for (var ele in listOfTasks) {
        taskList.add(
          TaskModel.fromMap(ele),
        );
      }

      await taskLocalRepository.insertTasks(taskList);

      return taskList;
    } catch (e) {
      final tasks = await taskLocalRepository.getTask();
      if (tasks.isNotEmpty) {
        return tasks;
      }
      rethrow;
    }
  }

  Future<bool> syncTasks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = [];
      for (final task in tasks) {
        taskListInMap.add(task.toMap());
      }
      final res =
          await http.post(Uri.parse("${Constants.backendUri}/tasks/sync"),
              headers: {
                'Content-Type': 'application.json',
                'x-auth-token': token,
              },
              body: jsonEncode(taskListInMap));

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
