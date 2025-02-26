import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/utils.dart';
import 'package:frontend/home/repository/task_local_repository.dart';
import 'package:frontend/home/repository/task_remote_repository.dart';
import 'package:frontend/model/task_model.dart';


part 'add_new_task_state.dart';

class AddNewTaskCubit extends Cubit<AddNewTaskState> {
   AddNewTaskCubit() : super(AddNewTaskInitial());
  final taskRemoteRepository = TaskRemoteRepository();
  final taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required Color color,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      emit(AddNewTaskLoading());
      final taskModel = await taskRemoteRepository.createTask(
          uid: uid,
          title: title,
          description: description,
          hexColor: rgbToHex(color),
          token: token,
          dueAt: dueAt);

      await taskLocalRepository.inserTask(taskModel);

      emit(AddNewTaskSuccess([taskModel]));
    } catch (e) {
      emit(AddNewTaskError(e.toString()));
    }
  }

  Future<void> getAllTasks({required String token}) async {
    try {
      emit(AddNewTaskLoading());
      final tasks = await taskRemoteRepository.getTask(
        token: token,
      );

      final nonNullTasks =
          tasks.where((task) => task != null).cast<TaskModel>().toList();

      emit(GetTasksSuccess(nonNullTasks));
    } catch (e) {
      emit(AddNewTaskError(e.toString()));
    }
  }

  Future<void> syncTasks(String token) async {
    final unsyncedTasks = await taskLocalRepository.getUnsyncTasks();

    if (unsyncedTasks.isEmpty) {
      return;
    }

    final nonNullUnsyncedTasks = unsyncedTasks.where((task) => task != null).cast<TaskModel>().toList();
    final isSynced = await taskRemoteRepository.syncTasks(
        token: token, tasks: nonNullUnsyncedTasks);

    if (isSynced) {
      for (final task in unsyncedTasks) {
        if (task != null) {
          taskLocalRepository.updateRowValue(task.id, 1);
        }
      }
    }
  }
}
